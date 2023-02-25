// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../interfaces/IAuthorize.sol";

contract Authorizer is IAuthorize {

    struct AuthorizerParams {
        bool doAuth;
        address owner;
    }

    AuthorizerParams public params;
    // IAuthorize

    constructor(bool _doAuth) {
        params.doAuth = _doAuth;
        params.owner = msg.sender;
    }

    function canAttest(address profile) external view returns (bool) {
        require(profile == params.owner);
        return params.doAuth;
    }
}