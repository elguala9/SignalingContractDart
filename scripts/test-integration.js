#!/usr/bin/env node

/**
 * Script di integrazione automatico: avvia Hardhat node, deploya e testa
 * Funziona su Windows, macOS e Linux
 */

const { spawn, spawnSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const http = require('http');

const colors = {
  reset: '\x1b[0m',
  yellow: '\x1b[33m',
  green: '\x1b[32m',
  red: '\x1b[31m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function error(message) {
  log(message, 'red');
  process.exit(1);
}

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function waitForHardhat(url, maxRetries = 60) {
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
      log('Hardhat è pronto!', 'green');
      // Extra wait to ensure node is fully initialized
      await sleep(5000);
      return;
    } catch (err) {
      if (i % 10 === 0) {
        log(`Tentativo ${i + 1}/${maxRetries}... (${err.message})`, 'yellow');
      }
      await sleep(1000);
    }
  }
  error(`Errore: Hardhat non ha risposto dopo ${maxRetries} secondi`);
}

function runCommand(cmd, args, cwd, label) {
  return new Promise((resolve, reject) => {
    log(`Eseguendo: ${cmd} ${args.join(' ')}`, 'yellow');
    const proc = spawn(cmd, args, {
      cwd,
      stdio: 'inherit',
      shell: true,
    });
    proc.on('close', (code) => {
      if (code !== 0) {
        error(`${label} fallito con codice ${code}`);
      }
      resolve();
    });
    proc.on('error', reject);
  });
}

async function main() {
  const projectRoot = path.resolve(__dirname, '..');
  const tsContractDir = path.join(projectRoot, 'packages', 'typescript', 'signaling-contract');
  const dartSdkDir = path.join(projectRoot, 'packages', 'contract_sdk');
  const rpcUrl = 'http://127.0.0.1:8545';  // Use IPv4 explicitly to avoid IPv6 issues on Windows
  const tokenInfoPath = path.join(projectRoot, 'packages', 'token_info.txt');

  let hardhatProcess = null;

  // Cleanup function
  const cleanup = () => {
    if (hardhatProcess) {
      log('Terminando Hardhat node...', 'yellow');
      hardhatProcess.kill('SIGTERM');
    }
  };

  process.on('SIGINT', () => {
    cleanup();
    process.exit(0);
  });
  process.on('SIGTERM', () => {
    cleanup();
    process.exit(0);
  });

  try {
    // 1. Avviare Hardhat node in background
    log('[1/4] Avviando Hardhat node...', 'yellow');

    // Wait a moment to allow TIME_WAIT sockets to clear on Windows
    log('   Waiting for port 8545 to be available...', 'yellow');
    await sleep(15000);

    hardhatProcess = spawn('npm', ['run', 'network'], {
      cwd: tsContractDir,
      stdio: ['ignore', 'pipe', 'pipe'],
      shell: true,
      env: { ...process.env, NODE_OPTIONS: '--no-warnings' },
    });

    let hardhatStarted = false;
    hardhatProcess.stdout?.on('data', (data) => {
      const output = data.toString();
      if (output.includes('Started HTTP') || output.includes('listening')) {
        log('Hardhat ha avviato il server HTTP', 'green');
        hardhatStarted = true;
      }
      if (process.env.DEBUG_HARDHAT) {
        console.log('[HARDHAT OUT]', output);
      }
    });

    hardhatProcess.stderr?.on('data', (data) => {
      const errMsg = data.toString();
      if (errMsg.includes('EADDRINUSE')) {
        log('⚠️  Port 8545 in use, Hardhat may retry...', 'yellow');
      } else if (errMsg.trim()) {
        console.log('[HARDHAT STDERR]', errMsg);
      }
    });

    // 2. Aspettare che Hardhat sia pronto
    log('[2/4] Aspettando che Hardhat sia pronto...', 'yellow');
    await waitForHardhat(rpcUrl);

    // 3. Deployare il contratto con retry
    log('[3/4] Deployando il contratto...', 'yellow');
    let deploySuccess = false;
    let lastError = null;
    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        log(`   Tentativo di deploy ${attempt}/3...`, 'yellow');
        await runCommand('npm', ['run', 'deploySC'], tsContractDir, 'Deploy');
        deploySuccess = true;
        break;
      } catch (err) {
        lastError = err;
        if (attempt < 3) {
          log(`   Deployment failed, retrying in 5 seconds...`, 'yellow');
          await sleep(5000);
        }
      }
    }
    if (!deploySuccess) {
      throw lastError || new Error('Deploy failed after 3 attempts');
    }

    // Estrarre l'indirizzo
    const contractAddress = fs.readFileSync(tokenInfoPath, 'utf-8').trim();
    log(`Contratto deployato a: ${contractAddress}`, 'green');

    // Use the standard Hardhat account 0 from the default mnemonic
    // "test test test test test test test test test test test junk"
    // This is a well-known test mnemonic and these keys are public
    const privateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae2807';

    // 4. Eseguire i test Dart
    log('[4/4] Eseguendo i test Dart...', 'yellow');

    const env = {
      ...process.env,
      TEST_RPC_URL: rpcUrl,
      TEST_CONTRACT_ADDRESS: contractAddress,
      TEST_PRIVATE_KEY: privateKey,
    };

    console.log(`TEST_RPC_URL=${rpcUrl}`);
    console.log(`TEST_CONTRACT_ADDRESS=${contractAddress}`);
    console.log(`TEST_PRIVATE_KEY=${privateKey}`);

    await new Promise((resolve, reject) => {
      const dartTest = spawn('dart', ['test', 'test/signaling_contract_deploy_test.dart'], {
        cwd: dartSdkDir,
        stdio: 'inherit',
        shell: true,
        env,
      });

      dartTest.on('close', (code) => {
        if (code !== 0) {
          reject(new Error(`Dart test fallito con codice ${code}`));
        } else {
          resolve();
        }
      });
    });

    log('✓ Test completati con successo!', 'green');
  } catch (err) {
    error(`Errore durante l'esecuzione: ${err.message}`);
  } finally {
    cleanup();
  }
}

main().catch(err => {
  error(err.message || 'Errore sconosciuto');
});
