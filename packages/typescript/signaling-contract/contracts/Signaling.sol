// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import './ISignaling.sol';

import "@openzeppelin/contracts/access/Ownable.sol";

contract Signaling is ISignaling, Ownable{

    // address -> signal
    mapping (address => Signal) signals;

    constructor(address owner) Ownable(owner) {}

    function setSignal(bytes memory compressedSignal) external override {
        // Validate gzip format
        require(compressedSignal.length >= 2, "Invalid compressed data format");
        require(
            compressedSignal[0] == 0x1f && compressedSignal[1] == 0x8b,
            "Data must be in gzip format"
        );

        Signal memory signal = Signal(compressedSignal, block.timestamp);
        signals[msg.sender] = signal;
        emit SignalEmitted(msg.sender, compressedSignal, block.timestamp);
    }

    function getSignal(
        address offerer
    ) external view override returns (Signal memory) {
        return signals[offerer];
    }
}
