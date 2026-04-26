#!/usr/bin/env node
// Generate ABI from Solidity++ contract
const fs = require('fs');
const path = require('path');

// Parse Solidity++ contract to generate ABI
function generateABI() {
  const contractPath = path.join(__dirname, '../contracts/Signaling.solpp');
  const contractCode = fs.readFileSync(contractPath, 'utf8');

  // Manually define ABI based on contract analysis
  const abi = [
    {
      type: 'constructor',
      inputs: [
        {
          name: 'initialOwner',
          type: 'address',
          internalType: 'address'
        }
      ]
    },
    {
      type: 'event',
      name: 'OwnershipTransferred',
      inputs: [
        {
          name: 'previousOwner',
          type: 'address',
          indexed: true,
          internalType: 'address'
        },
        {
          name: 'newOwner',
          type: 'address',
          indexed: true,
          internalType: 'address'
        }
      ]
    },
    {
      type: 'event',
      name: 'SignalEmitted',
      inputs: [
        {
          name: 'offerer',
          type: 'address',
          indexed: true,
          internalType: 'address'
        },
        {
          name: 'compressedSignal',
          type: 'bytes',
          indexed: false,
          internalType: 'bytes'
        },
        {
          name: 'timestamp',
          type: 'uint256',
          indexed: false,
          internalType: 'uint256'
        }
      ]
    },
    {
      type: 'function',
      name: 'owner',
      inputs: [],
      outputs: [
        {
          name: '',
          type: 'address',
          internalType: 'address'
        }
      ],
      stateMutability: 'view'
    },
    {
      type: 'function',
      name: 'setSignal',
      inputs: [
        {
          name: 'compressedSignal',
          type: 'bytes',
          internalType: 'bytes memory'
        }
      ],
      outputs: [],
      stateMutability: 'nonpayable'
    },
    {
      type: 'function',
      name: 'getSignal',
      inputs: [
        {
          name: 'offerer',
          type: 'address',
          internalType: 'address'
        }
      ],
      outputs: [
        {
          name: '',
          type: 'tuple',
          internalType: 'struct ISignaling.Signal',
          components: [
            {
              name: 'data',
              type: 'bytes',
              internalType: 'bytes'
            },
            {
              name: 'timestamp',
              type: 'uint256',
              internalType: 'uint256'
            }
          ]
        }
      ],
      stateMutability: 'view'
    }
  ];

  // Save ABI to file
  const outputDir = path.join(__dirname, '../abi');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const abiPath = path.join(outputDir, 'Signaling.json');
  fs.writeFileSync(abiPath, JSON.stringify(abi, null, 2));
  console.log(`✅ ABI generated: ${abiPath}`);

  return abi;
}

if (require.main === module) {
  try {
    generateABI();
  } catch (error) {
    console.error('❌ Error generating ABI:', error.message);
    process.exit(1);
  }
}

module.exports = { generateABI };
