const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const steps = [
  {
    name: '📦 Compiling contract...',
    cmd: 'npm run compile',
  },
  {
    name: '📝 Generating TypeScript bindings...',
    cmd: 'node scripts/generate-ts-bindings.js',
  },
  {
    name: '🎯 Generating Dart bindings...',
    cmd: 'node scripts/generate-dart-bindings.js',
  },
];

console.log('\n🚀 Building Signaling SDK for Vite...\n');

try {
  for (const step of steps) {
    console.log(`${step.name}`);
    execSync(step.cmd, { stdio: 'inherit' });
    console.log('');
  }

  console.log('✨ SDK generation complete!\n');
  console.log('Generated files:');
  console.log('  📦 TypeScript: packages/vite/lib/generated/signaling-contract.ts');
  console.log('  📦 Dart: packages/vite_contract_sdk/lib/generated/signaling_contract.dart');
  console.log('  📦 Artifacts: packages/vite/build/Signaling.{abi.json,json,bin}');
  console.log('');
} catch (error) {
  console.error('\n❌ Build failed:', error.message);
  process.exit(1);
}
