// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IProfile {

    event Attest(address sender, uint256 index, string message);

    event AuthorizeChange(address authorizer, bool status);

    event Contest(uint256 index, string message);

   function attest(address _authorizer, string calldata message) external;

   function contest(address attester, uint256 index, string calldata reason) external;

}
