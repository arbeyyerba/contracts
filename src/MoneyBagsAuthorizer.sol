// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./interfaces/IAuthorize.sol";
import "./interfaces/IProfile.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//Error pattern = cheaper than require statements

contract MoneyBagsAuthorizer is IAuthorize {
    // Mainnet Polygon
    AggregatorV3Interface constant public priceFeed = 
        AggregatorV3Interface(
                0xAB594600376Ec9fD91F8e885dADF0CE036862dE0 //polygon MATIC/USD 0% 27s 8 decimals
            );
    
    mapping(address => bytes32) public hashedPosts;

    error NotEnoughTokens(uint256 amount);

    /// @notice Profile contract calls Authorizer contract
    /// @dev Need to validate msg.sender is an actual profile contract
    /// @dev Need to validate sender is the tx.origin
    function makeValidPost(address sender, address profile, string calldata message) external {
        //validate sender == tx.origin
        if(!_isMoneyBags(sender)) revert NotEnoughTokens(sender.balance);

        //Setting new hash after check completion
        bytes32 currentHash = hashedPosts[profile];
        currentHash ^= keccak256(abi.encodePacked(message));
        hashedPosts[profile] = currentHash;
    }

    function isPostValid(address sender, address profile, string calldata message) external view returns (bool) {
        return _isMoneyBags(sender);
    }

    function latestValidatedHash(address profile) external view returns (bytes32) {
        return hashedPosts[profile];
    }

    function getLatestPrice() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    
    /// @param sender is the original transaction sender
    function _isMoneyBags(address sender) internal view returns (bool) {
        //Authorizer requires profile to have a certain amount of USD value in the wallet
        //math: 8+18-18 = 8 decimals, checks if address has >= 10.00 USD worth of MATIC
        return (uint256(getLatestPrice()) * sender.balance / 1 ether) > 10e8;
    }
}
