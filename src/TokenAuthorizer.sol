// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IAuthorize.sol";
import "./interfaces/IProfile.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract TokenAuthorizer is IAuthorize {
    address erc20Address = 0x0;
    uint256 amount = 0;
    
    mapping(address => bytes32) public hashPosts;

    error NotEnoughTokens(address sender);
    error InvalidCaller(address profile);

    constructor(address _erc20Address, uint256 _amount) {
        erc20Address = _erc20Address;
        amount = _amount;

    }

    /// @notice Profile contract calls Authorizer contract
    /// @dev Need to validate msg.sender is an actual profile contract
    /// @dev Need to validate sender is the tx.origin
    function makeValidPost(address sender, address profile, string calldata message) external {
        //validate sender == tx.origin
        //validate caller is the profile

        if(!_hasTokens(IProfile(profile).getOwner())) revert NotEnoughTokens(profileOwner);
        if(!_hasTokens(sender)) revert NotEnoughTokens(sender);
        if(!profile == msg.sender) revert InvalidCaller(profile);

        //Setting new hash after check completion
        bytes32 currentHash = hashedPosts[profile];
        currentHash ^= keccak256(abi.encodePacked(message));
        hashPosts[profile] = currentHash;
    }

    function isValidPost(address sender, address profile, string calldata message) external view returns (bool) {
        return _hasTokens(IProfile(profile).getOwner()) && _hasTokens(sender);
    }

    function getLatestValidatedHash(address profile) external view returns (bytes32) {
        return hashPosts[profile];
    }

    /// @param sender is the original transaction sender
    function _hasTokens(address sender) internal view returns (bool) {
        //Sender required to have a EthDenver2023 NFT ticket
        return (IERC20(erc20Address).balanceOf(sender) > amount)
    }
}
