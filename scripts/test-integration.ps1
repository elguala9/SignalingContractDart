# Script di integrazione automatico: avvia Hardhat node, deploya e testa
# Versione PowerShell per Windows

$ErrorActionPreference = "Stop"

$ProjectRoot = (Get-Item (Split-Path $PSScriptRoot)).FullName
$TsContractDir = "$ProjectRoot\packages\typescript\signaling-contract"
$DartSdkDir = "$ProjectRoot\packages\contract_sdk"
$RpcUrl = "http://localhost:8545"
$HardhatProcess = $null

# Funzione di cleanup
function Cleanup {
    if ($HardhatProcess -and -not $HardhatProcess.HasExited) {
        Write-Host "Terminando Hardhat node (PID: $($HardhatProcess.Id))..." -ForegroundColor Yellow
        $HardhatProcess | Stop-Process -Force -ErrorAction SilentlyContinue
        $HardhatProcess.Dispose()
    }
}

trap {
    Cleanup
    exit 1
}

# 1. Avviare Hardhat node in background
Write-Host "[1/4] Avviando Hardhat node..." -ForegroundColor Yellow
Push-Location $TsContractDir
$HardhatProcess = Start-Process npm `
    -ArgumentList "run", "network" `
    -NoNewWindow `
    -PassThru `
    -RedirectStandardOutput "C:\tmp\hardhat.log" `
    -RedirectStandardError "C:\tmp\hardhat_err.log"

Write-Host "Hardhat PID: $($HardhatProcess.Id)"

# 2. Aspettare che Hardhat sia pronto
Write-Host "[2/4] Aspettando che Hardhat sia pronto..." -ForegroundColor Yellow
$MaxRetries = 30
$Retry = 0
while ($Retry -lt $MaxRetries) {
    try {
        $response = Invoke-WebRequest `
            -Uri $RpcUrl `
            -Method Post `
            -ContentType "application/json" `
            -Body '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' `
            -UseBasicParsing `
            -ErrorAction SilentlyContinue

        if ($response.Content -contains "0x") {
            Write-Host "Hardhat è pronto!" -ForegroundColor Green
            break
        }
    } catch {
        # Retry
    }

    $Retry++
    Write-Host "Tentativo $Retry/$MaxRetries..."
    Start-Sleep -Seconds 1
}

if ($Retry -eq $MaxRetries) {
    Write-Host "Errore: Hardhat non ha risposto dopo $MaxRetries secondi" -ForegroundColor Red
    Cleanup
    exit 1
}

# 3. Deployare il contratto
Write-Host "[3/4] Deployando il contratto..." -ForegroundColor Yellow
npm run deploySC 2>&1 | Tee-Object -FilePath "C:\tmp\deploy.log"

# Estrarre l'indirizzo dal file token_info.txt
$ContractAddress = (Get-Content "$ProjectRoot\packages\token_info.txt").Trim()
Write-Host "Contratto deployato a: $ContractAddress" -ForegroundColor Green

# Hardhat usa questa private key per il primo account
$PrivateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb476cadeee4c811daadc2bae28078"

# 4. Eseguire i test Dart
Write-Host "[4/4] Eseguendo i test Dart..." -ForegroundColor Yellow
Pop-Location
Push-Location $DartSdkDir

# Passare le variabili d'ambiente ai test
$env:TEST_RPC_URL = $RpcUrl
$env:TEST_CONTRACT_ADDRESS = $ContractAddress
$env:TEST_PRIVATE_KEY = $PrivateKey

Write-Host "TEST_RPC_URL=$($env:TEST_RPC_URL)"
Write-Host "TEST_CONTRACT_ADDRESS=$($env:TEST_CONTRACT_ADDRESS)"
Write-Host "TEST_PRIVATE_KEY=$($env:TEST_PRIVATE_KEY)"

dart test test/signaling_contract_deploy_test.dart -v

Write-Host "✓ Test completati con successo!" -ForegroundColor Green

Cleanup
Pop-Location
