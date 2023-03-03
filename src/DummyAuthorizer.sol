// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IAuthorize.sol";
import "./interfaces/IProfile.sol";

contract DummyAuthorizer is IAuthorize {
    
    mapping(address => bytes32) hashedAttests;

    // function validateTransaction(address profile, address target, string calldata message) external returns (bool) {
    function validateTransaction(address profile, address target, string calldata message) external returns (bool) {
        bytes32 currentHash = hashedAttests[profile];
        currentHash ^= keccak256(abi.encodePacked(message));
        hashedAttests[profile] = currentHash;
        return true;
    }

    function getLatestValidatedHash(address profile) external view returns (bytes32) {
        return hashedAttests[profile];
    }
}
