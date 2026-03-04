#!/usr/bin/env node

/**
 * Docker integration test: starts Ganache via docker-compose,
 * builds and runs the deployer Docker image, then runs Dart tests.
 */

const { spawn, execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const http = require('http');
const net = require('net');

const colors = {
  reset: '\x1b[0m',
  yellow: '\x1b[33m',
  green: '\x1b[32m',
  red: '\x1b[31m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function waitForRpc(url, maxRetries = 60) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      await new Promise((resolve, reject) => {
        const req = http.request(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          timeout: 5000,
        }, (res) => {
          let data = '';
          res.on('data', chunk => data += chunk);
          res.on('end', () => {
            if (data && data.length > 0) resolve();
            else reject(new Error('Empty response'));
          });
        });
        req.on('error', reject);
        req.on('timeout', () => { req.destroy(); reject(new Error('Timeout')); });
        req.write(JSON.stringify({ jsonrpc: '2.0', method: 'eth_blockNumber', params: [], id: 1 }));
        req.end();
      });
      log('   Ganache is ready!', 'green');
      await sleep(2000);
      return;
    } catch (err) {
      if (i % 10 === 0) {
        log(`   Waiting... attempt ${i + 1}/${maxRetries} (${err.message})`, 'yellow');
      }
      await sleep(1000);
    }
  }
  throw new Error(`Ganache did not respond after ${maxRetries} seconds`);
}

function runCommand(cmd, args, cwd, env) {
  return new Promise((resolve, reject) => {
    const proc = spawn(cmd, args, {
      cwd,
      stdio: 'inherit',
      shell: true,
      env: env || process.env,
    });
    proc.on('close', (code) => {
      if (code !== 0) reject(new Error(`Command failed with exit code ${code}`));
      else resolve();
    });
    proc.on('error', reject);
  });
}

/**
 * Run a command quietly: capture stdout and stderr, only show stderr on failure.
 * Returns stdout.
 */
function runCommandQuiet(cmd, args, cwd, env) {
  return new Promise((resolve, reject) => {
    let stdout = '';
    let stderr = '';
    const proc = spawn(cmd, args, {
      cwd,
      stdio: ['ignore', 'pipe', 'pipe'],
      shell: true,
      env: env || process.env,
    });
    proc.stdout.on('data', (data) => { stdout += data.toString(); });
    proc.stderr.on('data', (data) => { stderr += data.toString(); });
    proc.on('close', (code) => {
      if (code !== 0) {
        process.stderr.write(stderr);
        reject(new Error(`Command failed with exit code ${code}\n${stderr}`));
      } else {
        resolve(stdout);
      }
    });
    proc.on('error', reject);
  });
}

/**
 * Run a command and capture stdout (shown live). Stderr is only shown on failure.
 * Returns stdout.
 */
function runCommandCapture(cmd, args, cwd, env) {
  return new Promise((resolve, reject) => {
    let stdout = '';
    let stderr = '';
    const proc = spawn(cmd, args, {
      cwd,
      stdio: ['ignore', 'pipe', 'pipe'],
      shell: true,
      env: env || process.env,
    });
    proc.stdout.on('data', (data) => {
      const s = data.toString();
      stdout += s;
      process.stdout.write(s);
    });
    proc.stderr.on('data', (data) => { stderr += data.toString(); });
    proc.on('close', (code) => {
      if (code !== 0) {
        process.stderr.write(stderr);
        reject(new Error(`Command failed with exit code ${code}\n${stderr}`));
      } else {
        resolve(stdout);
      }
    });
    proc.on('error', reject);
  });
}

async function main() {
  const projectRoot = path.resolve(__dirname, '..');
  const tsContractDir = path.join(projectRoot, 'packages', 'typescript', 'signaling-contract');
  const dartSdkDir = path.join(projectRoot, 'packages', 'contract_sdk');
  const rpcUrl = 'http://127.0.0.1:8545';
  const dockerImage = 'signaling-contract-deployer:test';

  // Well-known test mnemonic account 0 (without 0x, as required by entrypoint.sh)
  const privateKeyNoPrefix = 'ac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807';
  const privateKeyWithPrefix = '0x' + privateKeyNoPrefix;

  // Track containers we stopped to restart them after tests
  let stoppedContainerId = null;
  let stoppedContainerName = null;

  const cleanup = async () => {
    log('Cleaning up Docker resources...', 'yellow');
    try {
      execSync('docker compose down --remove-orphans --volumes', { cwd: projectRoot, stdio: 'ignore' });
    } catch (e) { /* ignore */ }
    // Force-remove the container if it's still lingering
    try {
      execSync('docker rm -f parresia-contract-ganache', { stdio: 'ignore' });
    } catch (e) { /* ignore */ }
  };

  process.on('SIGINT', async () => { await cleanup(); process.exit(0); });
  process.on('SIGTERM', async () => { await cleanup(); process.exit(0); });

  try {
    // 1. Start Ganache via docker-compose
    log('[1/5] Starting Ganache via docker-compose...', 'yellow');
    await cleanup(); // ensure clean state

    // Check port 8545 is free before starting Ganache
    log('   Checking port 8545...', 'yellow');
    const portFree = await new Promise((resolve) => {
      const server = net.createServer();
      server.once('error', () => resolve(false));
      server.once('listening', () => { server.close(); resolve(true); });
      server.listen(8545);
    });
    if (!portFree) {
      // Try to find and stop the Docker container using port 8545
      log('   Port 8545 busy, looking for Docker container to stop...', 'yellow');
      try {
        const containerId = execSync(
          'docker ps --filter "publish=8545" --format "{{.ID}} {{.Names}}"',
          { encoding: 'utf-8' }
        ).trim();
        if (containerId) {
          const [id, name] = containerId.split(' ');
          log(`   Stopping container "${name}" (${id}) on port 8545...`, 'yellow');
          execSync(`docker stop ${id}`, { stdio: 'ignore' });
          stoppedContainerId = id;
          stoppedContainerName = name;
          log(`   Stopped. Will restart after tests.`, 'green');
        }
      } catch (e) { /* ignore */ }
      // Wait for port to actually free up
      for (let i = 0; i < 15; i++) {
        const free = await new Promise((resolve) => {
          const server = net.createServer();
          server.once('error', () => resolve(false));
          server.once('listening', () => { server.close(); resolve(true); });
          server.listen(8545);
        });
        if (free) break;
        if (i === 14) throw new Error('Port 8545 still busy after stopping containers');
        await sleep(1000);
      }
    }
    log('   Port 8545 is available', 'green');

    await runCommandQuiet('docker', ['compose', 'up', '-d', 'ganache'], projectRoot);
    log('   Ganache container started', 'green');

    // 2. Wait for Ganache to be ready
    log('[2/5] Waiting for Ganache...', 'yellow');
    await waitForRpc(rpcUrl);

    // 3. Build deployer Docker image
    log('[3/5] Building deployer Docker image...', 'yellow');
    await runCommandQuiet('docker', ['build', '-t', dockerImage, '.'], tsContractDir);
    log('   Docker image built', 'green');

    // 4. Deploy contract using Docker image
    // Don't pass PRIVATE_KEY: let Hardhat use the mnemonic (same as Ganache)
    // so that account 0 is 0xf39F... with pre-funded balance
    log('[4/5] Deploying contract via Docker image...', 'yellow');
    const deployOutput = await runCommandCapture('docker', [
      'run', '--rm',
      '--network', 'parresia-contract-network',
      '-e', 'RPC_URL=http://ganache:8545',
      dockerImage,
    ], projectRoot);

    // Extract contract address from output
    const addressMatch = deployOutput.match(/CONTRACT_ADDRESS=(0x[0-9a-fA-F]+)/);
    if (!addressMatch) {
      throw new Error('Could not extract contract address from Docker deploy output');
    }
    const contractAddress = addressMatch[1];
    log(`   Contract deployed at: ${contractAddress}`, 'green');

    // Save to token_info.txt for consistency
    fs.writeFileSync(path.join(projectRoot, 'packages', 'token_info.txt'), contractAddress);

    // 5. Run all Dart tests
    log('[5/5] Running Dart tests...', 'yellow');

    const testEnv = {
      ...process.env,
      TEST_RPC_URL: rpcUrl,
      TEST_CONTRACT_ADDRESS: contractAddress,
      TEST_PRIVATE_KEY: privateKeyWithPrefix,
    };

    await new Promise((resolve, reject) => {
      const dartTest = spawn('dart', ['test'], {
        cwd: dartSdkDir,
        stdio: 'inherit',
        shell: true,
        env: testEnv,
      });
      dartTest.on('close', (code) => {
        if (code !== 0) reject(new Error(`Dart tests failed with exit code ${code}`));
        else resolve();
      });
      dartTest.on('error', reject);
    });

    log('All tests passed! (Docker)', 'green');
  } catch (err) {
    log(`Error: ${err.message}`, 'red');
    process.exitCode = 1;
  } finally {
    await cleanup();
    // Restart any container we stopped
    if (stoppedContainerId) {
      log(`Restarting container "${stoppedContainerName}" (${stoppedContainerId})...`, 'yellow');
      try {
        execSync(`docker start ${stoppedContainerId}`, { stdio: 'ignore' });
        log(`   Restarted "${stoppedContainerName}"`, 'green');
      } catch (e) {
        log(`   Could not restart "${stoppedContainerName}": ${e.message}`, 'red');
      }
    }
  }
}

main();
