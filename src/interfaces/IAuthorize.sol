// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAuthorize {

    //Authorizer defines criteria to approve transaction
    function isApprovedToSend(address sender) external view returns (bool);

    //Authorizer defines critera to receive transaction
    function isApprovedToReceive(address receiver) external view returns (bool);

    //Authorizer authenticates transaction data from approver and receive
    function isValidTransactions(address profile, address target) external view returns (bool);
}