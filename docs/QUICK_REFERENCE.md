# 🚀 Quick Reference - Melos Commands

## TL;DR - Main Commands

### Setup (First Time)
```bash
melos run dev:setup
```

### Build Everything (Most Common)
```bash
melos run contracts:build
```

### Build Only Dart Bindings
```bash
melos run contracts:build:dart
```

### Validate Types
```bash
melos run contracts:build  # includes validation
# OR
npm run validate  # direct validation
```

### Clean
```bash
melos run clean
```

---

## All Melos Commands

| Command | Purpose |
|---------|---------|
| `melos run contracts:build` | Full build: TS + Dart + validate |
| `melos run contracts:build:typechain` | TypeScript types only |
| `melos run contracts:build:dart` | Dart bindings only |
| `melos run dev:setup` | Initial setup (dependencies + build) |
| `melos run analyze` | Analyze all Dart packages |
| `melos run test` | Run all tests |
| `melos run format` | Format all code |
| `melos run clean` | Clean all artifacts |

---

## Typical Workflow

1. **Modify contract**
   ```bash
   # Edit: packages/typescript/signaling-contract/contracts/Signaling.sol
   ```

2. **Build**
   ```bash
   melos run contracts:build
   ```

3. **Commit**
   ```bash
   git add packages/
   git commit -m "Update contract"
   ```

4. **Push**
   ```bash
   git push
   # GitHub Actions automatically verifies everything
   ```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Binding out of sync | `melos run contracts:build` |
| Dart analysis errors | `cd packages/contract_sdk && dart pub get` |
| TypeScript errors | `cd packages/typescript/signaling-contract && npm install && npm run build:contracts` |
| Full reset | `melos run clean && melos run dev:setup` |
