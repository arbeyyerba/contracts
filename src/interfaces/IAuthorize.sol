// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAuthorize {

    //to avoid spam
    //Authorizer decides criteria to accept profile
    function canAttest(address profile) external view returns (bool);
}