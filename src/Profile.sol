// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IProfile.sol";
import "./interfaces/IAuthorize.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
    @notice This is the first iteration of a Profile contract. This contract has basic functionality.
        Store the attests and contests of users as strings on-chain given they meet the Authorizer's 
        criteria. Future implementations will use a different more efficient storage method. 
 */

contract Profile is IProfile, Ownable {

    address[] authorizedContracts;
    mapping(address => mapping(uint256 => string)) public contestations;
    mapping(address => string[]) public attestations;

    //encodePacked(address, string[index]) = more gas efficient, future gas optimization

    //
    // EXTERNAL
    //

    /// @notice Attesters needs profile address, authorizer address, and attest message, IPFS CID (32bytes)
    function attest(address _authorizer, string calldata message) external {
        require(isAuthorizer(_authorizer), "Authorizer Denied");
        require(IAuthorize(_authorizer).isApprovedToSend(msg.sender), "Sender Denied");
        require(IAuthorize(_authorizer).isApprovedToReceive(owner()), "Receiver Denied");

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
    function contest(address attester, uint256 index, string calldata message) external onlyOwner {
        contestations[attester][index] = message;
        emit Contest(index, message);
    }

    //
    // EXTERNAL VIEW
    //

    function getOwner() external view returns (address) {
        return owner();
    }

    function getContest(address sender, uint256 index) external view returns (string memory) {
        return contestations[sender][index];
    }

    function getAttestation(address sender, uint256 index) external view returns (string memory) {
        return attestations[sender][index];
    }

    function getAuthorizerList(address[] calldata authorizers) external pure returns (address[] calldata) {
        return authorizers;
    }

    //
    // PUBLIC VIEW
    //

    function getAttestLength(address sender) public view returns (uint256) {
        return attestations[sender].length;
    }

    function isAuthorizer(address _authorizer) public view returns (bool) {
        for(uint i=0; i < authorizedContracts.length; i++) {
            if(authorizedContracts[i] == _authorizer) {
                return true;
            }
        }

        return false;
    }
}