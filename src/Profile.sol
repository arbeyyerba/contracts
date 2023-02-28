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

    //authorizer to sender
    mapping(address => address[]) public attesters;

    //sender to messages
    mapping(address => string[]) public attestations;

    //sender to string index to message
    mapping(address => mapping(uint256 => string)) public contestations;


    //encodePacked(address, string[index]) = more gas efficient, future gas optimization

    error AuthorizerDenied();
    error SenderDenied(address sender);
    error ReceiverDenied(address receiver);

    constructor() {
        //put string name storage here
    }

    //
    // EXTERNAL
    //

    /// @notice Attesters needs profile address, authorizer address, and attest message, IPFS CID (32bytes)
    function attest(address _authorizer, string calldata message) external nonReentrant {
        if(!isAuthorizer(_authorizer)) revert AuthorizerDenied();
        if(!IAuthorize(_authorizer).isApprovedToSend(msg.sender)) revert SenderDenied(msg.sender);
        if(!IAuthorize(_authorizer).isApprovedToReceive(owner())) revert ReceiverDenied(owner());

        if(isAttester(_authorizer, msg.sender)) 
            attesters[_authorizer].push(msg.sender);
        attestations[msg.sender].push(message);
        emit Attest(msg.sender, getAttestLength(msg.sender) - 1, message);
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
    function contest(address sender, uint256 index, string calldata message) external onlyOwner {
        contestations[sender][index] = message;
        emit Contest(sender, index, message);
    }

    //
    // EXTERNAL VIEW
    //

    function getOwner() external view returns (address) {
        return owner();
    }

    /// @dev Get a list of all authorizers
    function getAuthorizerList(address[] calldata authorizers) public pure returns (address[] calldata) {
        return authorizers;
    }

    /// @dev Get a list of all senders from an authorizer
    function getAttesters(address authorizer) public view returns (address[] memory) {
        return attesters[authorizer];
    }

    /// @dev Get a list of all messages from a sender
    function getAttestations(address sender) external view returns (string[] memory) {
        return attestations[sender];
    }

    /// @dev Get a specific message from sender at index
    function getAttestation(address sender, uint256 index) external view returns (string memory) {
        return attestations[sender][index];
    }

     /// @dev Get a specific message from sender at index
    function getContest(address sender, uint256 index) external view returns (string memory) {
        return contestations[sender][index];
    }

    //
    // PUBLIC VIEW
    //

    /// @dev Get total length of message array
    function getAttestLength(address sender) public view returns (uint256) {
        return attestations[sender].length;
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

    /// @dev Check if sender is in authorizer array
    function isAttester(address authorizer, address sender) public view returns (bool) {
        address[] memory array = getAttesters(authorizer);
        for(uint i=0; i < array.length; i++) {
            if(array[i] == sender) {
                return true;
            }
        }

        return false;
    }
}