// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IProfile.sol";
import "./interfaces/IAuthorize.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract Profile is IProfile, Ownable, ReentrancyGuard {

    struct Attestation {
        address submitter;
        address authorizer;
        bytes hash;
    }

    struct Contestation {
        address submitter;
        uint256 attestationId;
        bytes hash;
    }

    mapping(address => bool) public authorizedContracts;
    mapping(uint256 => Contestation) public contestations;


    // TODO we can probably drop the address mapping to save on gas/space. We likely want to
    // see *all* the attestations on the ui anyways.
    //returns the hash of attestation, must be decoded by authorizer
    mapping(uint256 => Attestation) public attestations;

    //use counters if necessary
    uint256 id = 0;
    uint256 contestId = 0;

    //
    // EXTERNAL
    //

    function attest(address authorizer, string calldata attestData) external {
        require(authorizedContracts[authorizer], "Not a valid Authorizer for this profile");
        require(IAuthorize(authorizer).canAttest(msg.sender), "Not authorized to attest");

        bytes memory attestHash = abi.encode(attestData);

        Attestation memory attestation = attestations[id];
        attestation.submitter = msg.sender;
        attestation.authorizer = authorizer;
        attestation.hash = attestHash;

        // TODO is it worth putting all the other attestation details in the event?
        emit Attest(msg.sender, id, attestHash);
        id++;
    }

    //
    // EXTERNAL Only-Owner
    //

    /// @dev Add authorizer
    function addAuthorizer(address newAuthorizer) external onlyOwner {
        authorizedContracts[newAuthorizer] = true;
        emit AuthorizeChange(newAuthorizer);
    }

    /// @dev Removes authorizer
    function removeAuthorizer(address badAuthorizer) external onlyOwner{
        authorizedContracts[badAuthorizer] = false;
        // TODO why not add the new state (true/false)?
        emit AuthorizeChange(badAuthorizer);
    }

    /// @dev Stores contest data onchain
    function contest(uint256 attestationId, string calldata reason) external onlyOwner {

        bytes memory contestHash = abi.encode(reason);

        Contestation memory contestation = contestations[contestId];
        contestation.submitter = msg.sender;
        contestation.attestationId = attestationId;
        contestation.hash = contestHash;

        emit Contest(attestationId, reason);
    }

    //
    // EXTERNAL VIEW
    //

    function viewContest(uint256 _id) external view returns (string memory) {
        return _decodeContest(contestations[_id].hash);
    }

    function viewAttestation(uint256 _id) external view returns (string memory) {
        return _decodeAttest(attestations[_id].hash);
    }

    function isAuthorizer(address authorizer) external view returns (bool) {
        return authorizedContracts[authorizer];
    }

    //
    // INTERNAL
    //
    //
    function _decodeAttest(bytes storage data) internal pure returns (string memory) {
        // TODO the data will likely live off-chain.
        return string(bytes(abi.decode(data, (string))));
    }

    function _decodeContest(bytes storage data) internal pure returns (string memory) {
        // TODO the data will likely live off-chain.
        return string(bytes(abi.decode(data, (string))));
    }

}
