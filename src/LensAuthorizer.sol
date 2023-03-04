// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IAuthorize.sol";
import "./interfaces/IProfile.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//Error pattern = cheaper than require statements

contract NftAuthorizer is IAuthorize {
    // Mainnet Polygon
    address erc721Contract = 0xDb46d1Dc155634FbC732f92E853b10B288AD5a1d;
    
    mapping(address => bytes32) public hashedPosts;

    error NoLensProfile(address target);

    constructor(address _erc721Contract) {
        erc721Contract = _erc721Contract;
    }

    /// @notice Profile contract calls Authorizer contract
    /// @dev Need to validate msg.sender is an actual profile contract
    /// @dev Need to validate sender is the tx.origin
    function makeValidPost(address sender, address profile, string calldata message) external {
        //validate profile address, maybe use factory pattern?
        //validate sender == tx.origin
        if(!_hasNft(IProfile(profile).profileOwner())) revert NoLensProfile(IProfile(profile).profileOwner());
        if(!_hasNft(sender)) revert NoLensProfile(sender);

        //Setting new hash after check completion
        bytes32 currentHash = hashedPosts[profile];
        currentHash ^= keccak256(abi.encodePacked(message));
        hashedPosts[profile] = currentHash;
    }

    function isPostValid(address sender, address profile, string calldata message) external view returns (bool) {
        return _hasNft(IProfile(profile).profileOwner()) && _hasNft(sender);
    }

    function latestValidatedHash(address profile) external view returns (bytes32) {
        return hashedPosts[profile];
    }

    /// @param sender is the original transaction sender
    function _hasNft(address sender) internal view returns (bool) {
        //Sender required to have a EthDenver2023 NFT ticket
        return (IERC721(erc721Contract).balanceOf(sender) > 0);
    }
}
