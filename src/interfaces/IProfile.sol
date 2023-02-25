// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IProfile {

    event Attest(address);

    event Authorize(address);

    event Contest(uint256 id, bytes message);

   function attest() external;

   function delegate(address newDelegate) external;

   function revoke(AttestParams memory params) external;


}
