// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IProfile {

    event Attest(address);

    event Delegate(address);

    event Revoke(AttestParams);

   function attest(AttestParams memory params) external;

   function delegate(address newDelegate) external;

   function revoke(AttestParams memory params) external;


}
