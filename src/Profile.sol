// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IProfile.sol";
import "./interfaces/IAuthorize.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Profile is IProfile, Ownable {
    using Counters for Counters.Counter;

    mapping(address => bool) public authorizedContract;
    mapping(uint256 => bytes) contestations;
    //returns the hash of attestation, must be decoded by authorizer
    mapping(address => mapping(uint256 => bytes)) attestations;

    uint256 id;

    //
    // EXTERNAL
    //

    function attest(address _authorizer, bytes _attest) external {
        require(authorizedContract[_authorizer], "Not Authorized");
        require(IAuthorize(_authorizer).canAttest(msg.sender), "Authorizer Denied");        
        Counters.increment(id);
        attestations[msg.sender][Counters.current(id)] = _attest;
    }

    //
    // EXTERNAL Only-Owner
    //

    /// @dev Add authorizer
    function addAuthorizer(address newAuthorizer) external onlyOwner {
        authorizedContract[newAuthorizer] = true;
    }

    /// @dev Removes authorizer
    function removeAuthorizer(address badAuthorizer) external onlyOwner{
        authorizedContract[badAuthorizer] = false;
    }

    /// @dev Stores contest data onchain
    function contest(uint256 _id, bytes reason) external onlyOwner {
        contestations[id] = reason;
    }

    //
    // EXTERNAL VIEW
    //

    function viewContest(uint256 _id) external view returns (bytes) {
        return contestations[_id];
    }

    function viewAttestation(address _authorizer, uint256 _id) external view returns (bytes) {
        require(authorizedContract[_authorizer], "Not Authorized");
        return IAuthorize(_authorized).decodeAttest(attestations[_authorizer][_id]);
    }
}