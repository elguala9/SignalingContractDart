// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

struct Signal {
    bytes signal;
    uint256  creationTime;
}

interface ISignaling {
    event SignalEmitted(address indexed sender, bytes signal, uint256 timestamp);

    function setSignal(bytes memory compressedSignal) external;

    function getSignal(address offerer) external view returns (Signal memory);
}
