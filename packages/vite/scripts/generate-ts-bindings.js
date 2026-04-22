const fs = require('fs');
const path = require('path');

// Paths
const buildDir = path.join(__dirname, '..', 'build');
const abiFile = path.join(buildDir, 'Signaling.abi.json');
const bytecodeFile = path.join(buildDir, 'Signaling.bin');

// Check artifacts exist
if (!fs.existsSync(abiFile) || !fs.existsSync(bytecodeFile)) {
  console.error('❌ Artifacts not found. Run "npm run compile" first.');
  process.exit(1);
}

const abi = JSON.parse(fs.readFileSync(abiFile, 'utf-8'));
const bytecode = fs.readFileSync(bytecodeFile, 'utf-8').trim();

// Create output directory
const outputDir = path.join(__dirname, '..', 'lib', 'generated');
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

// Generate TypeScript binding
const template = `// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from Signaling.solpp

import { Address, Bytes, Hex, encodePacked, toHex } from 'viem';
import type { PublicClient, WalletClient } from 'viem';

export interface SignalStruct {
  signal: Hex;
  creationTime: bigint;
}

export const SIGNALING_ABI = ${JSON.stringify(abi, null, 2)} as const;

export const SIGNALING_BYTECODE = '0x${bytecode}' as const;

export class SignalingContract {
  constructor(
    readonly address: Address,
    readonly publicClient: PublicClient,
    readonly walletClient?: WalletClient,
  ) {}

  // View Methods

  async getOwner(): Promise<Address> {
    const result = await this.publicClient.readContract({
      address: this.address,
      abi: SIGNALING_ABI,
      functionName: 'owner',
    });
    return result as Address;
  }

  async getSignal(offerer: Address): Promise<SignalStruct> {
    const result = await this.publicClient.readContract({
      address: this.address,
      abi: SIGNALING_ABI,
      functionName: 'getSignal',
      args: [offerer],
    });
    return result as SignalStruct;
  }

  // Write Methods

  async setSignal(
    compressedSignal: Hex,
    options?: { account?: Address; chainId?: number },
  ): Promise<Hex> {
    if (!this.walletClient) {
      throw new Error('walletClient is required for write operations');
    }

    const account = options?.account;
    const chainId = options?.chainId;

    const hash = await this.walletClient.writeContract({
      account,
      address: this.address,
      abi: SIGNALING_ABI,
      functionName: 'setSignal',
      args: [compressedSignal],
      chain: chainId ? { id: chainId } : undefined,
    });

    return hash;
  }

  // Deployment

  static async deploy(
    walletClient: WalletClient,
    initialOwner: Address,
    options?: { chainId?: number },
  ): Promise<Address> {
    const hash = await walletClient.deployContract({
      abi: SIGNALING_ABI,
      bytecode: SIGNALING_BYTECODE,
      args: [initialOwner],
      chain: options?.chainId ? { id: options.chainId } : undefined,
    });

    return hash;
  }
}

// Event Type Definitions
export interface OwnershipTransferredEvent {
  previousOwner: Address;
  newOwner: Address;
}

export interface SignalEmittedEvent {
  sender: Address;
  signal: Hex;
  timestamp: bigint;
}
`;

fs.writeFileSync(
  path.join(outputDir, 'signaling-contract.ts'),
  template,
);

console.log('✅ TypeScript bindings generated at: lib/generated/signaling-contract.ts');
