// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IAuthorize.sol";
import "./interfaces/IProfile.sol";

contract DummyAuthorizer is IAuthorize {

    mapping(address => bytes32) hashedPosts;

    error InvalidCaller(address profile);

    // function validateTransaction(address profile, address target, string calldata message) external returns (bool) {
    function makeValidPost(address sender, address profile, string calldata message) external {
        if(!profile == msg.sender) revert InvalidCaller(profile);

        bytes32 currentHash = hashedPosts[profile];
        currentHash ^= keccak256(abi.encodePacked(message));
        hashedPosts[profile] = currentHash;
    }

    function isValidPost(address sender, address profile, string calldata message) external returns (bool) {
        return true;
    }

    function latestValidatedHash(address profile) external view returns (bytes32) {
        return hashedPosts[profile];
    }
}
