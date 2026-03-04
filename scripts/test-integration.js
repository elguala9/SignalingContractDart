#!/usr/bin/env node

/**
 * Script di integrazione automatico: avvia Hardhat node, deploya e testa
 * Funziona su Windows, macOS e Linux
 */

const { spawn } = require('child_process');
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
        req.on('timeout', () => {
          req.destroy();
          reject(new Error('Timeout'));
        });
        req.write(JSON.stringify({
          jsonrpc: '2.0',
          method: 'eth_blockNumber',
          params: [],
          id: 1,
        }));
        req.end();
      });
      log('   Hardhat node is ready!', 'green');
      await sleep(2000);
      return;
    } catch (err) {
      if (i % 10 === 0) {
        log(`   Waiting... attempt ${i + 1}/${maxRetries} (${err.message})`, 'yellow');
      }
      await sleep(1000);
    }
  }
  throw new Error(`Hardhat did not respond after ${maxRetries} seconds`);
}

async function isPortFree(port) {
  return new Promise((resolve) => {
    const server = net.createServer();
    server.once('error', () => resolve(false));
    server.once('listening', () => {
      server.close();
      resolve(true);
    });
    server.listen(port);
  });
}

function runCommand(cmd, args, cwd) {
  return new Promise((resolve, reject) => {
    const proc = spawn(cmd, args, {
      cwd,
      stdio: 'inherit',
      shell: true,
    });
    proc.on('close', (code) => {
      if (code !== 0) reject(new Error(`Command failed with exit code ${code}`));
      else resolve();
    });
    proc.on('error', reject);
  });
}

async function main() {
  const projectRoot = path.resolve(__dirname, '..');
  const tsContractDir = path.join(projectRoot, 'packages', 'typescript', 'signaling-contract');
  const dartSdkDir = path.join(projectRoot, 'packages', 'contract_sdk');
  const rpcUrl = 'http://127.0.0.1:8545';
  const tokenInfoPath = path.join(projectRoot, 'packages', 'token_info.txt');

  let hardhatProcess = null;

  const cleanup = () => {
    if (hardhatProcess) {
      log('Stopping Hardhat node...', 'yellow');
      try {
        // On Windows, kill the process tree
        if (process.platform === 'win32') {
          spawn('taskkill', ['/pid', String(hardhatProcess.pid), '/f', '/t'], { shell: true, stdio: 'ignore' });
        } else {
          hardhatProcess.kill('SIGTERM');
        }
      } catch (e) {
        // ignore kill errors
      }
      hardhatProcess = null;
    }
  };

  process.on('SIGINT', () => { cleanup(); process.exit(0); });
  process.on('SIGTERM', () => { cleanup(); process.exit(0); });
  process.on('exit', cleanup);

  try {
    // 1. Wait for port 8545 to be available
    log('[1/4] Starting Hardhat node...', 'yellow');
    log('   Checking port 8545...', 'yellow');
    for (let i = 0; i < 30; i++) {
      if (await isPortFree(8545)) break;
      if (i === 0) log('   Port 8545 busy, waiting...', 'yellow');
      if (i === 29) throw new Error('Port 8545 still busy after 30 seconds');
      await sleep(1000);
    }
    log('   Port 8545 is available', 'green');

    hardhatProcess = spawn('npm', ['run', 'network'], {
      cwd: tsContractDir,
      stdio: ['ignore', 'pipe', 'pipe'],
      shell: true,
      env: { ...process.env, NODE_OPTIONS: '--no-warnings' },
    });

    hardhatProcess.stdout?.on('data', (data) => {
      if (process.env.DEBUG_HARDHAT) console.log('[HARDHAT]', data.toString());
    });
    hardhatProcess.stderr?.on('data', (data) => {
      const msg = data.toString().trim();
      if (msg && process.env.DEBUG_HARDHAT) console.log('[HARDHAT ERR]', msg);
    });

    hardhatProcess.on('exit', (code) => {
      if (code !== null && code !== 0) {
        log(`   Hardhat process exited with code ${code}`, 'red');
      }
    });

    // 2. Wait for Hardhat to be ready
    log('[2/4] Waiting for Hardhat node...', 'yellow');
    await waitForRpc(rpcUrl);

    // 3. Deploy the contract (with retry)
    log('[3/4] Deploying contract...', 'yellow');
    let deploySuccess = false;
    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        log(`   Deploy attempt ${attempt}/3...`, 'yellow');
        await runCommand('npm', ['run', 'deploySC'], tsContractDir);
        deploySuccess = true;
        break;
      } catch (err) {
        if (attempt < 3) {
          log(`   Deploy failed, retrying in 3 seconds...`, 'yellow');
          await sleep(3000);
        }
      }
    }
    if (!deploySuccess) throw new Error('Deploy failed after 3 attempts');

    const contractAddress = fs.readFileSync(tokenInfoPath, 'utf-8').trim();
    log(`   Contract deployed at: ${contractAddress}`, 'green');

    // Well-known Hardhat test private key (account 0)
    const privateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807';

    // 4. Run all Dart tests
    log('[4/4] Running Dart tests...', 'yellow');

    const env = {
      ...process.env,
      TEST_RPC_URL: rpcUrl,
      TEST_CONTRACT_ADDRESS: contractAddress,
      TEST_PRIVATE_KEY: privateKey,
    };

    await new Promise((resolve, reject) => {
      const dartTest = spawn('dart', ['test'], {
        cwd: dartSdkDir,
        stdio: 'inherit',
        shell: true,
        env,
      });
      dartTest.on('close', (code) => {
        if (code !== 0) reject(new Error(`Dart tests failed with exit code ${code}`));
        else resolve();
      });
      dartTest.on('error', reject);
    });

    log('All tests passed!', 'green');
  } catch (err) {
    log(`Error: ${err.message}`, 'red');
    process.exitCode = 1;
  } finally {
    cleanup();
  }
}

main();
