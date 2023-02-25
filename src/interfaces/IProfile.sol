// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IProfile {

    event Attest(address sender, uint256 id, bytes attest);

    event AuthorizeChange(address authorizer);

    event Contest(uint256 id, string message);

   function attest(address _authorizer, string calldata _attest) external;

   function contest(uint256 _id, string calldata reason) external;


}
