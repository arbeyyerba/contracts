// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAuthorize {

    //to avoid spam
    //Authorizer decides criteria to accept profile
    function canAttest(address profile) external view returns (bool);

    //has to be decoded by authorizer because profile does not know what the attest params
    //are, authorizer handles that
    function decodeAttest(bytes calldata data) external view returns (string memory);
}