// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import './ISignaling.sol';

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Signaling is ISignaling, UUPSUpgradeable, OwnableUpgradeable{

    // offerer -> offer
    mapping (address => Signal) offers;
    // answerer -> offerer -> answer
    mapping (address => mapping(address => Signal)) answers;

    uint32 version;
    uint256[50] _gap;

    function initialize(address owner) public initializer {
        __Ownable_init(owner);
    }


    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {
        version++;
    }

    modifier requireOffer(address offerer){
        require(offers[offerer].creationTime > 0, "No offer found");
        _;
    }

    function setOffer(bytes memory offer) external override {
        Signal memory signal = Signal(offer, block.timestamp);
        offers[msg.sender] = signal;
        emit proposeOffer(msg.sender, signal);
    }

    function setAnswer(
        bytes memory answer,
        address offerer
    ) external override requireOffer(offerer){
        Signal memory signal = Signal(answer, block.timestamp);
        answers[msg.sender][offerer] = signal;
        emit proposeAnswer(offerer, msg.sender, signal);
    }

    function getOffer(
        address offerer
    ) external view override returns (Signal memory) {
        return offers[offerer];
    }

    function getAnswer(
        address answerer,
        address offerer
    ) external view override returns (Signal memory) {
        return answers[answerer][offerer];
    }
}
