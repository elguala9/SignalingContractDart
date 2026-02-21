# Integration Testing Scripts

Questo folder contiene gli script per automatizzare i test di integrazione del contratto intelligente.

## Quick Start

Esegui i test di integrazione completamente automatizzati con:

```bash
melos run test:integration
```

Questo comando farà tutto automaticamente:
1. ✅ Avvia Hardhat node (localhost:8545)
2. ✅ Aspetta che sia pronto
3. ✅ Compila e deploya il contratto Signaling
4. ✅ Esegue tutti i test di integrazione Dart
5. ✅ Ripulisce e termina Hardhat

## Scripts Disponibili

### `test-integration.js` (Consigliato)
Script Node.js **cross-platform** che funziona su Windows, macOS e Linux.

**Esecuzione diretta:**
```bash
node scripts/test-integration.js
```

**Esecuzione via Melos:**
```bash
melos run test:integration
```

### `test-integration.sh` (Linux/macOS)
Script Bash per sistemi Unix.

**Esecuzione:**
```bash
bash scripts/test-integration.sh
```

### `test-integration.ps1` (Windows PowerShell)
Script PowerShell per Windows nativo (senza WSL).

**Esecuzione:**
```powershell
.\scripts\test-integration.ps1
```

## Cosa Succede

1. **Avvio di Hardhat Node**
   - Viene avviato il nodo Hardhat sulla porta 8545
   - Lo script aspetta che il nodo sia pronto prima di procedere (max 30 secondi)

2. **Deploy del Contratto**
   - Esegue `npm run deploySC` dal folder `packages/typescript/signaling-contract`
   - L'indirizzo del contratto viene salvato in `packages/token_info.txt`

3. **Esecuzione dei Test Dart**
   - I test leggono automaticamente:
     - `TEST_RPC_URL`: URL del nodo Hardhat
     - `TEST_CONTRACT_ADDRESS`: Indirizzo del contratto deployato
     - `TEST_PRIVATE_KEY`: Chiave privata del primo account (deterministica in Hardhat)

4. **Cleanup Automatico**
   - Il nodo Hardhat viene terminato automaticamente al termine
   - Anche in caso di errore (signal handling)

## Variabili d'Ambiente

Gli script passano automaticamente queste variabili d'ambiente ai test Dart:

| Variabile | Valore | Sorgente |
|-----------|--------|---------|
| `TEST_RPC_URL` | `http://localhost:8545` | Hardhat node |
| `TEST_CONTRACT_ADDRESS` | Indirizzo del contratto | File `token_info.txt` |
| `TEST_PRIVATE_KEY` | Chiave privata del deployer | Hardhat (account 0) |

## Troubleshooting

### "Hardhat non ha risposto"
- Assicurati che la porta 8545 non sia già in uso
- Prova a killare manualmente: `pkill -f "hardhat node"` (Linux/macOS) o `Get-Process | Where-Object {$_.Name -like "*hardhat*"} | Stop-Process` (PowerShell)
- Aumenta il timeout nello script se hai un PC lento

### "Contract address not found"
- Assicurati che `npm run deploySC` sia stato eseguito correttamente
- Verifica che il file `token_info.txt` esista e contenga un indirizzo valido

### Test falliscono per timeout
- I test potrebbero fallire se il nodo Hardhat è molto lento
- Prova ad aumentare i timeout nei test Dart

## Test Manuali (Opzionale)

Se vuoi eseguire i test manualmente:

```bash
# Terminal 1: Avvia Hardhat node
cd packages/typescript/signaling-contract
npm run network

# Terminal 2: Deploya il contratto
cd packages/typescript/signaling-contract
npm run deploySC

# Terminal 3: Esegui i test
cd packages/contract_sdk
TEST_RPC_URL=http://localhost:8545 dart test test/signaling_contract_deploy_test.dart -v
```

## Files Modificati

- `melos.yaml`: Aggiunto script `test:integration`
- `packages/contract_sdk/test/signaling_contract_deploy_test.dart`: Decommentati e adattati i test
- `packages/contract_sdk/test/README.md`: Aggiornate le istruzioni
