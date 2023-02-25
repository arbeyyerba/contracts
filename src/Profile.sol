// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IProfile.sol";
import "./interfaces/IAuthorize.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Profile is IProfile, Ownable {

    mapping(address => bool) public authorizedContract;
    mapping(uint256 => string) public contestations;
    //returns the hash of attestation, must be decoded by authorizer
    mapping(address => mapping(uint256 => bytes)) public attestations;

    //use counters if necessary
    uint256 id = 0;

    //
    // EXTERNAL
    //

    function attest(address _authorizer, string calldata _attest) external {
        require(authorizedContract[_authorizer], "Not Authorized");
        require(IAuthorize(_authorizer).canAttest(msg.sender), "Authorizer Denied");        
        bytes memory attestHash = abi.encode(_attest);
        attestations[msg.sender][id] = attestHash;
        emit Attest(msg.sender, id, attestHash);
        id++;
    }

    //
    // EXTERNAL Only-Owner
    //

    /// @dev Add authorizer
    function addAuthorizer(address newAuthorizer) external onlyOwner {
        authorizedContract[newAuthorizer] = true;
        emit AuthorizeChange(newAuthorizer);
    }

    /// @dev Removes authorizer
    function removeAuthorizer(address badAuthorizer) external onlyOwner{
        authorizedContract[badAuthorizer] = false;
        emit AuthorizeChange(badAuthorizer);
    }

    /// @dev Stores contest data onchain
    function contest(uint256 _id, string calldata reason) external onlyOwner {
        contestations[id] = reason;
        emit Contest(_id, reason);
    }

    //
    // EXTERNAL VIEW
    //

    function viewContest(uint256 _id) external view returns (string memory) {
        return contestations[_id];
    }

    function viewAttestation(address _authorizer, uint256 _id) external view returns (string memory) {
        require(authorizedContract[_authorizer], "Not Authorized");
        return _decodeAttest(attestations[_authorizer][_id]);
    }

    function isAuthorizer(address _authorizer) external view returns (bool) {
        return authorizedContract[_authorizer];
    }

    //internal atm
    function _decodeAttest(bytes storage data) internal pure returns (string memory) {
        return string(bytes(abi.decode(data, (string))));
    }

}