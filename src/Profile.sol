// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IProfile.sol";

contract Profile is IProfile {
    mapping(address => bool) authorizedContract;

    mapping(address => mapping(uint256 => AttestParams)) attestations;

    function attest(AttestParams memory params) external {

    }

    //authorize = authorized contracts to do stuff
    function authorize(address newAuthorizer) external {
        
    }

    //pointer to AttestParams
    function revoke(AttestParams memory params) external {

    }
}