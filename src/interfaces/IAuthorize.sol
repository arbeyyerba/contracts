// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAuthorize {

    struct AuthorizationParams {
        uint256 valueTotal;
    }
    //to avoid spam
    //Authorizer decides criteria to accept profile
    function canAttest(address profile) external view returns (bool);

    //
    function decodeAttest(bytes calldata data) external view returns (bytes memory);
}