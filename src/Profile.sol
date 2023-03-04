// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IProfile.sol";
import "./interfaces/IAuthorize.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/**
    @notice This is the first iteration of a Profile contract. This contract has basic functionality.
        Store the attests and contests of users as strings on-chain given they meet the Authorizer's 
        criteria. Future implementations will use a different more efficient storage method. 
 */

contract Profile is IProfile, Ownable, ReentrancyGuard {

    string ownerName;

    //profile to authorizers
    address[] authorizedContracts;

    //authorizer to messages
    mapping(address => Attestation[]) public attestations;

    //authorizer and index to message
    mapping(address => mapping(uint256 => string)) public contestations;

    error AuthorizerDenied();

    constructor(string memory _ownerName) {
        ownerName = _ownerName;
    }

    //
    // EXTERNAL
    //

    /// @notice Attesters needs profile address, authorizer address, and attest message, IPFS CID (32bytes)
    function addPost(address _authorizer, string calldata message) external nonReentrant {
        if(!isAuthorizer(_authorizer)) revert AuthorizerDenied();
        IAuthorize(_authorizer).makeValidPost(msg.sender, address(this), message);

        attestations[_authorizer].push(Attestation(msg.sender, message));
        emit Attest(msg.sender, _authorizer, postLengthByAuthorizer(_authorizer) - 1);
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

        // TODO this feels very janky.
        bool found = false;
        for(uint i=0; i < authorizedContracts.length; i++) {
            if(authorizedContracts[i] == badAuthorizer) {
                found = true;
            }
            if (found && i+1<authorizedContracts.length) {
                authorizedContracts[i] = authorizedContracts[i+1];
            }
        }
        if (found) {
            authorizedContracts.pop();
        }
        emit AuthorizeChange(badAuthorizer, false);
    }

    /// @dev Stores contest message onchain
    function addComment(address _authorizer, uint256 index, string calldata message) external onlyOwner {
        contestations[_authorizer][index] = message;
        emit Contest(_authorizer, index);
    }

    /// @notice allow the owner to delete content they do not agree with. However, this will make the message hashes
    /// not match what the authorizer has on file, so anyone will know the messages were modified.
    function deletePost(address authorizer, uint256 index) external onlyOwner {
        attestations[authorizer][index]=Attestation(address(this), '');
    }

    /// @notice Allow the owner to delete content they do not agree with, while still enabling
    /// a viewer to recompute the correct hash of all posts.
    /// @dev by putting the hash at the deleted message, someone looking at this profile could identify this
    /// as the deleted message, and use it to continue calculating the true hash.
    /// This lets the user know both that a) a message was deleted and b) *which* message was deleted, while
    /// still verifying that no other messages were tampered with.
    ///
    /// By using the contract address as the sender, we also indicate that this is a 'magic' value,
    /// not a real attestation.
    function deletePostWithHash(address authorizer, uint256 index, bytes32 hash) external onlyOwner {
        string memory hashAsString = string(abi.encodePacked(hash));
        attestations[authorizer][index]=Attestation(address(this), hashAsString);
    }

    /// @dev Set new owner name
    function setOwnerName(string calldata _newOwnerName) external onlyOwner {
        ownerName = _newOwnerName;
    }

    //
    // EXTERNAL VIEW
    //

    function profileOwner() external view returns (address) {
        return owner();
    }

    /// @dev Get a list of all messages from a sender
    function postsByAuthorizer(address authorizer) external view returns (Attestation[] memory) {
        return attestations[authorizer];
    }

    /// @dev Get a specific message from sender at index
    function postByAuthorizerAndIndex(address authorizer, uint256 index) external view returns (Attestation memory) {
        return attestations[authorizer][index];
    }

     /// @dev Get a specific message from sender at index
    function commentByAuthorizerAndIndex(address authorizer, uint256 index) external view returns (string memory) {
        return contestations[authorizer][index];
    }

    function getAuthorizerList() external view returns (address[] memory) {
        return authorizedContracts;
    }

    //
    // PUBLIC VIEW
    //

    /// @dev Get total length of message array
    function postLengthByAuthorizer(address authorizer) public view returns (uint256) {
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

    function getMetadataUri() public view returns (string memory) {
        return string(
            abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(string(abi.encodePacked("{\"name\":\"", ownerName, "\"}")))))
        );
    }
}
