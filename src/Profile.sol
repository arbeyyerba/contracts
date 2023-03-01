// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IProfile.sol";
import "./interfaces/IAuthorize.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
    @notice This is the first iteration of a Profile contract. This contract has basic functionality.
        Store the attests and contests of users as strings on-chain given they meet the Authorizer's 
        criteria. Future implementations will use a different more efficient storage method. 
 */

contract Profile is IProfile, Ownable, ReentrancyGuard {

    //profile to authorizers
    address[] authorizedContracts;

    //encodePacked(address, string[index]) = more gas efficient, future gas optimization
    //authorizer to messages
    mapping(address => Attestation[]) public attestations;

    //authorizer and index to message
    mapping(address => mapping(uint256 => string)) public contestations;


    error AuthorizerDenied();
    error TransactionDenied(address sender, address authorizer);

    constructor() {
        //put string name storage here
    }

    //
    // EXTERNAL
    //

    /// @notice Attesters needs profile address, authorizer address, and attest message, IPFS CID (32bytes)
    function attest(address _authorizer, string calldata message) external nonReentrant {
        if(!isAuthorizer(_authorizer)) revert AuthorizerDenied();
        if(!(IAuthorize(_authorizer).validateTransaction(msg.sender, address(this), message))) 
            revert TransactionDenied(msg.sender, _authorizer);

        attestations[_authorizer].push(Attestation(msg.sender, message));
        emit Attest(msg.sender, _authorizer, getAttestLength(_authorizer) - 1);
    }

    //
    // EXTERNAL Only-Owner
    //

    /// @dev Add authorizer
    function addAuthorizer(address newAuthorizer) external onlyOwner {
        authorizedContracts.push(newAuthorizer);
        emit AuthorizeChange(newAuthorizer, true);
    }

    /// @dev Removes authorizer
    function removeAuthorizer(address badAuthorizer) external onlyOwner{
        authorizedContracts.push(badAuthorizer);
        emit AuthorizeChange(badAuthorizer, false);
    }

    /// @dev Stores contest message onchain
    function contest(address _authorizer, uint256 index, string calldata message) external onlyOwner {
        contestations[_authorizer][index] = message;
        emit Contest(_authorizer, index);
    }

    // allow the owner to delete content they do not agree with. However, this will make the message hashes
    // not match what the authorizer has on file, so anyone will know the messages were modified.
    function deleteAttestation(address authorizer, uint256 index) external onlyOwner {
        attestations[authorizer][index]=Attestation(address(this), '');
    }

    // by putting the hash at the deleted message, someone looking at this profile could identify this
    // as the deleted message, and use it to continue calculating the true hash.
    // This lets the user know both that a) a message was deleted and b) *which* message was deleted, while
    // still verifying that no other messages were tampered with.
    //
    // By using the contract address as the sender, we also indicate that this is a 'magic' value,
    // not a real attestation.
    function deleteAttestationWithHash(address authorizer, uint256 index, bytes32 hash) external onlyOwner {
        string memory hashAsString = string(abi.encodePacked(hash));
        attestations[authorizer][index]=Attestation(address(this), hashAsString);
    }

    //
    // EXTERNAL VIEW
    //

    function getOwner() external view returns (address) {
        return owner();
    }

    /// @dev Get a list of all messages from a sender
    function getAttestations(address authorizer) external view returns (Attestation[] memory) {
        return attestations[authorizer];
    }

    /// @dev Get a specific message from sender at index
    function getAttestation(address authorizer, uint256 index) external view returns (Attestation memory) {
        return attestations[authorizer][index];
    }

     /// @dev Get a specific message from sender at index
    function getContest(address authorizer, uint256 index) external view returns (string memory) {
        return contestations[authorizer][index];
    }

    function getAuthorizerList() external view returns (address[] memory) {
        return authorizedContracts;
    }

    //
    // PUBLIC VIEW
    //

    /// @dev Get total length of message array
    function getAttestLength(address authorizer) public view returns (uint256) {
        return attestations[authorizer].length;
    }

    /// @dev Check if authorizer in authorizer array
    function isAuthorizer(address _authorizer) public view returns (bool) {
        for(uint i=0; i < authorizedContracts.length; i++) {
            if(authorizedContracts[i] == _authorizer) {
                return true;
            }
        }

        return false;
    }
}
