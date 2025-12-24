// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

struct Signal {
    bytes signal;
    uint256  creationTime;
}

interface ISignaling {
    event proposeOffer(address indexed offerer, Signal offer);
    event proposeAnswer(address indexed offerer, address indexed answerer, Signal answer);

    function setOffer(bytes memory offer) external;
    function setAnswer(bytes memory answer, address offerer) external;

    function getOffer(address offerer) external view returns (Signal memory);
    function getAnswer(address answerer, address offerer) external view returns (Signal memory);
}
