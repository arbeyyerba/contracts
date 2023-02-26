// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAuthorize {

    //Authorizer defines criteria to approve transaction
    function isApprovedToSend(address profile) external view returns (bool);

    //Authorizer defines critera to receive transaction
    function isApprovedToReceive(address profile) external view returns (bool);
}