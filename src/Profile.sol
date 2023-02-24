// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IProfile.sol";
import "./mocks/Counters.sol";

contract Profile is IProfile {
    using Counters for Counters.Counter;

    mapping(address => bool) authorizedContract;
    
    uint256 id;

    //put in authorization contract
    //mapping(address => mapping(uint256 => AttestParams)) attestations;

    function attest(AttestParams memory params) external {
        Counters.increment(id);
    }

    //authorize = authorized contracts to do stuff
    function addAuthorizer(address newAuthorizer) external {
        authorizedContract[newAuthorizer] = true;
    }

    function removeAuthorizer(address badAuthorizer) external {
        authorizedContract[badAuthorizer] = false;
    }

    //pointer to AttestParams
    function revoke(uint256 _id) external {

    }
}