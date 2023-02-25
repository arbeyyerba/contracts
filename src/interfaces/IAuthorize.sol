// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAuthorize {

    //To avoid user getting spammed
    //Authorizer decides criteria to accept profile
    function canAttest(address profile) external view returns (bool);

    //To ensure receivers meet criteria
    //Helps mitigate against corrupt Endorsers
    //Authorizer decides critera to receive attest
    function canReceive(address profile) external view returns (bool);
}