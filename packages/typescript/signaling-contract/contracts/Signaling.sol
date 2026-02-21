// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import './ISignaling.sol';

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Signaling is ISignaling, UUPSUpgradeable, OwnableUpgradeable{

    // address -> signal
    mapping (address => Signal) signals;

    uint32 version;
    uint256[50] _gap;

    function initialize(address owner) public initializer {
        __Ownable_init(owner);
    }


    function _authorizeUpgrade(address) internal override onlyOwner {
        version++;
    }

    function setSignal(bytes memory compressedSignal) external override {
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
