// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./interfaces/IAuthorize.sol";
import "./interfaces/IProfile.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenAuthorizer is IAuthorize {
    address erc20Address;
    uint256 amount;
    
    mapping(address => bytes32) public hashedPosts;

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

        if(!_hasTokens(IProfile(profile).profileOwner())) revert NotEnoughTokens(IProfile(profile).profileOwner());
        if(!_hasTokens(sender)) revert NotEnoughTokens(sender);
        //if(profile != msg.sender) revert InvalidCaller(profile);

        //Setting new hash after check completion
        bytes32 currentHash = hashedPosts[profile];
        currentHash ^= keccak256(abi.encodePacked(message));
        hashedPosts[profile] = currentHash;
    }

    function isPostValid(address sender, address profile, string calldata message) external view returns (bool) {
        return _hasTokens(IProfile(profile).profileOwner()) && _hasTokens(sender);
    }

    function latestValidatedHash(address profile) external view returns (bytes32) {
        return hashedPosts[profile];
    }

    /// @param sender is the original transaction sender
    function _hasTokens(address sender) internal view returns (bool) {
        //Sender required to have a EthDenver2023 NFT ticket
        return IERC20(erc20Address).balanceOf(sender) > amount;
    }
}
