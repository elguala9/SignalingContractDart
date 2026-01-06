# Guida alla Pubblicazione su pub.dev

## Checklist Pre-Pubblicazione

Verifiche completate prima della pubblicazione:

### ✅ Configurazione del Pacchetto
- [x] **pubspec.yaml** - Nome, versione, descrizione, home/repository URL
- [x] **Authors/Publisher** - Informazioni autore aggiunte
- [x] **Topics** - Tag rilevanti per la scoperta del pacchetto
- [x] **SDK Environment** - Dart >=3.0.0 <4.0.0
- [x] **Dependencies** - web3dart ^3.0.1, wallet ^0.0.14

### ✅ Documentazione
- [x] **README.md** - Documentazione completa e professionale con badge
- [x] **CHANGELOG.md** - Storico versioni in formato standard (Keep a Changelog)
- [x] **LICENSE** - LGPL-3.0 license inclusa
- [x] **Documentation Link** - Link a pub.dev documentation nel pubspec

### ✅ Esportazioni e API
- [x] **lib/signaling_contract_sdk.dart** - File di esportazione principale
- [x] **Export Statement** - Esporta SignalingContract e tipi principali
- [x] **Documentazione inline** - Package-level documentation con esempi

### ✅ Contenuti del Pacchetto
- [x] **lib/** - Codice sorgente ben organizzato
- [x] **example/** - Esempio completo di utilizzo
- [x] **test/** - Suite di test (39 test)
- [x] **.pubignore** - Esclude file non necessari per pub.dev

### ✅ Qualità del Codice
- [x] **dart analyze** - Nessun errore di compilazione
- [x] **dart test** - Tutti i test passano
- [x] **Code style** - Segue le convenzioni Dart
- [x] **Linting** - Solo info su print (accettabili)

## Istruzioni di Pubblicazione

### 1. Preparazione Finale

```bash
# Navigare nella cartella del package
cd packages/contract_sdk

# Pulire dipendenze precedenti
rm -rf .dart_tool pubspec.lock

# Ottenere le nuove dipendenze
dart pub get

# Eseguire analisi finale
dart analyze

# Eseguire i test
dart test
```

### 2. Dry-run della Pubblicazione

```bash
# Simulare la pubblicazione senza pubblicare effettivamente
dart pub publish --dry-run
```

Questo comando:
- Valida il pubspec.yaml
- Verifica che tutti i file obbligatori siano presenti
- Controlla i permessi e la documentazione
- Mostra una preview di cosa sarà pubblicato

### 3. Verificare l'Output del Dry-run

Output atteso:
```
Publishing signaling_contract_sdk 1.0.0 to https://pub.dev:
|-- lib/
|   |-- generated/
|   |   |-- contracts.dart
|   |   |-- signaling_contract.dart
|   |-- signaling_contract_sdk.dart
|-- example/
|   |-- main.dart
|-- test/
|-- README.md
|-- CHANGELOG.md
|-- LICENSE
```

### 4. Pubblicare il Pacchetto

```bash
# Pubblicare su pub.dev (richiede autenticazione)
dart pub publish
```

**Note sulla Autenticazione:**
- Al primo publish, ti verrà chiesto di autenticarti con Google OAuth
- Segui il link fornito dal terminale
- Il credenziale viene salvato localmente in ~/.pub-cache/

### 5. Verifica Post-Pubblicazione

Dopo la pubblicazione (può richiedere 5-30 minuti):

1. Visita: https://pub.dev/packages/signaling_contract_sdk
2. Verifica:
   - Package page è visibile
   - README viene visualizzato
   - Versione 1.0.0 è disponibile
   - Documentation tab è disponibile
   - Example viene mostrato

3. Prova l'installazione:
   ```bash
   dart pub add signaling_contract_sdk
   ```

## Package Stats

**Informazioni del Pacchetto:**
- Nome: signaling_contract_sdk
- Versione: 1.0.0
- License: LGPL-3.0
- Dart SDK: >=3.0.0 <4.0.0
- Topics: blockchain, ethereum, smart-contracts, web3, evm

**Dipendenze Principali:**
- web3dart ^3.0.1
- wallet ^0.0.14
- convert ^3.1.1
- http ^1.1.0

**Dev Dependencies:**
- test ^1.24.0
- lints ^3.0.0

**Dimensione Stimata:**
- Approx. 20 KB compresso su pub.dev
- Circa 100 KB decompresso con dipendenze

## Aggiornamenti Futuri

### Per un nuovo Release (es. 1.1.0):

1. **Aggiorna versione** in pubspec.yaml:
   ```yaml
   version: 1.1.0
   ```

2. **Aggiorna CHANGELOG.md**:
   ```markdown
   ## [1.1.0] - YYYY-MM-DD
   
   ### Added
   - Nuova funzionalità X
   
   ### Fixed
   - Bug fix Y
   
   ### Changed
   - Miglioramento Z
   ```

3. **Commit e tag** con git:
   ```bash
   git add pubspec.yaml CHANGELOG.md
   git commit -m "chore: bump version to 1.1.0"
   git tag v1.1.0
   git push origin main --tags
   ```

4. **Pubblica** il nuovo release:
   ```bash
   dart pub publish
   ```

## Troubleshooting

### Errore: "Invalid pubspec"
- Verifica che pubspec.yaml sia YAML valido
- Assicurati che tutte le dipendenze siano pubbliche su pub.dev

### Errore: "Missing LICENSE"
- LICENSE file deve essere nella cartella root
- Deve essere nominato esattamente "LICENSE" (maiuscolo)

### Errore: "Documentation not generated"
- Assicurati che il pubspec abbia `documentation:` URL
- Pub.dev genererà automaticamente la documentazione da i file .dart

### Package non appare dopo 30 minuti
- Controlla status su https://pub.dev/packages/signaling_contract_sdk
- Talvolta ci vuole più tempo per essere indicizzato
- Verifica che non ci siano problemi nella build dei docs

### Errore di Autenticazione
```bash
# Se l'autenticazione fallisce, reset:
rm ~/.pub-cache/credentials.json

# Ripeti il publish
dart pub publish
```

## Risorsi Utili

- 📚 [Dart Pub Publishing Guide](https://dart.dev/tools/pub/publishing)
- 📖 [pubspec.yaml Reference](https://dart.dev/tools/pub/pubspec)
- 🔍 [pub.dev API Documentation](https://pub.dev/help)
- 🏆 [Pub Score Details](https://pub.dev/help#pub-score)
- 📋 [Keep a Changelog](https://keepachangelog.com)

## Monitoraggio Post-Pubblicazione

### Metriche da Monitorare:
- Download count su pub.dev
- GitHub stars/issues
- Community feedback
- Compatibilità con nuove versioni di Dart/web3dart

### Comunicazione:
- 📧 GitHub Discussions
- 🐛 GitHub Issues per bug report
- 💬 Dart Discord Community

---

**Stato**: ✅ **PRONTO PER LA PUBBLICAZIONE**
**Versione**: 1.0.0
**Data Preparazione**: 2025-01-06
**Prossimi Passi**: Eseguire `dart pub publish`
