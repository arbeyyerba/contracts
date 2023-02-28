// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IAuthorize.sol";
import "./interfaces/IProfile.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//Error pattern = cheaper than require statements

contract SporkAuthorizer is IAuthorize {
    // Mainnet Polygon
    AggregatorV3Interface constant public priceFeed = 
        AggregatorV3Interface(
                0xAB594600376Ec9fD91F8e885dADF0CE036862dE0 //polygon MATIC/USD 0% 27s 8 decimals
            );
    address constant public ethDenverNFT = 0x6C84D94E7c868e55AAabc4a5E06bdFC90EF3Bc72;

    error DidNotAttendEthDenver2023(address target);
    error NotEnoughTokens(uint256 amount);

    constructor() {
   
    }

    /// @notice Profile contract calls Authorizer contract. 
    /// @param sender is the original transaction sender
    function isApprovedToSend(address sender) external view returns (bool) {
        //Authorizer requires profile to have a certain amount of USD value in the wallet
        //math: 8+18-18 = 8 decimals, checks if address has > 0.01 USD worth of MATIC
        if(!(uint256(getLatestPrice()) * sender.balance / 1 ether > 1e6)) revert NotEnoughTokens(sender.balance);

        //Sender required to have a EthDenver2023 NFT ticket
        if(!(IERC721(ethDenverNFT).balanceOf(sender) > 0)) revert DidNotAttendEthDenver2023(sender);

        

        return true;
    }

    /// @notice Profile contract calls Authorizer contract
    /// @param profileOwner is the owner of the profile contract
    function isApprovedToReceive(address profileOwner) external view returns (bool) {
        //Receiver required to have a EthDenver2023 NFT ticket
        if(!(IERC721(ethDenverNFT).balanceOf(profileOwner) > 0)) revert DidNotAttendEthDenver2023(profileOwner);
        return true;
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
}