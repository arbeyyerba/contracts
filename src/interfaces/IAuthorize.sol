// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAuthorize {

    struct AuthorizationParams {
        uint256 valueTotal;
    }
    //to avoid spam
    function canAttest(address profile) external view returns (bool);
}