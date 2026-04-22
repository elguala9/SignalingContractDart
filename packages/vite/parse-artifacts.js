const fs = require('fs');

const output = fs.readFileSync('compile_output.txt', 'utf-8');
const lines = output.split('\n');

// Find contract name line and get ABI from next line
let abiLine = null;
let bytecodeLine = null;

for (let i = 0; i < lines.length; i++) {
  if (lines[i].trim() === 'Signaling') {
    abiLine = lines[i + 1];
    bytecodeLine = lines[i + 2];
    break;
  }
}

if (!abiLine || !bytecodeLine) {
  console.error('Could not find ABI or bytecode in output');
  process.exit(1);
}

const abi = JSON.parse(abiLine);
const bytecode = bytecodeLine.trim();

// Create build directory
if (!fs.existsSync('build')) {
  fs.mkdirSync('build');
}

// Save ABI
fs.writeFileSync('build/Signaling.abi.json', JSON.stringify(abi, null, 2));
console.log('✓ ABI saved to build/Signaling.abi.json');

// Save bytecode
fs.writeFileSync('build/Signaling.bin', bytecode);
console.log('✓ Bytecode saved to build/Signaling.bin');

// Save combined artifact
const artifact = {
  contractName: 'Signaling',
  abi,
  bytecode: '0x' + bytecode,
  deployedBytecode: '0x' + bytecode
};

fs.writeFileSync('build/Signaling.json', JSON.stringify(artifact, null, 2));
console.log('✓ Combined artifact saved to build/Signaling.json');

console.log('\n✅ All artifacts generated successfully!');
