// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAuthorize {

    //Authorizer authenticates transaction data from approver and receive
    function validateTransaction(address sender, address profile, string calldata message) external returns (bool);
    //Authorizer maintains a hash of all the messages it has authorizes for a profile
    function getLatestValidatedHash(address profile) external view returns (bytes32);
}
