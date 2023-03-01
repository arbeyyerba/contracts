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
    
    mapping(address => bytes32) public hashedAttests;

    error DidNotAttendEthDenver2023(address target);
    error NotEnoughTokens(uint256 amount);
    error InvalidHash(bytes32 currentHash, bytes32 storedHash);

    constructor() {
   
    }

    /// @notice Profile contract calls Authorizer contract
    /// @dev Need to validate msg.sender is an actual profile contract
    /// @dev Need to validate sender is the tx.origin
    function validateTransaction(address sender, address profile, string calldata message) external returns (bool) {
        //validate profile address, maybe use factory pattern?
        //validate sender == tx.origin
        _isApprovedToReceive(IProfile(profile).getOwner());
        _isApprovedToSend(sender);

        //validate current Attestation[] hash = latestHash
        bytes32 profileHashedData = _generateNewHash(IProfile(profile).getAttestations(sender));
        if(!(keccak256(abi.encodePacked(profileHashedData)) == keccak256(abi.encodePacked(hashedAttests[profile])))) 
            revert InvalidHash(profileHashedData, hashedAttests[profile]);

        //Setting new hash after check completion
        bytes32 currentHash = hashedAttests[profile];
        currentHash ^= keccak256(abi.encodePacked(message));
        hashedAttests[profile] = currentHash;
        return true;
    }

    function getLatestValidatedHash(address profile) external view returns (bytes32) {
        return hashedAttests[profile];
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
    function _isApprovedToSend(address sender) internal view returns (bool) {
        //Authorizer requires profile to have a certain amount of USD value in the wallet
        //math: 8+18-18 = 8 decimals, checks if address has > 0.01 USD worth of MATIC
        if(!(uint256(getLatestPrice()) * sender.balance / 1 ether > 1e6)) revert NotEnoughTokens(sender.balance);

        //Sender required to have a EthDenver2023 NFT ticket
        if(!(IERC721(ethDenverNFT).balanceOf(sender) > 0)) revert DidNotAttendEthDenver2023(sender);

        return true;
    }

    /// @param profileOwner is the owner of the profile contract
    function _isApprovedToReceive(address profileOwner) internal view returns (bool) {
        //Receiver required to have a EthDenver2023 NFT ticket
        if(!(IERC721(ethDenverNFT).balanceOf(profileOwner) > 0)) revert DidNotAttendEthDenver2023(profileOwner);

        return true;
    }

    /// @dev This generates the new hash of the current attestation[] on Profile
    function _generateNewHash(IProfile.Attestation[] memory data) internal pure returns (bytes32) {
        bytes32 hashedData;
        for(uint i = 0; i < data.length; i++){
            hashedData ^= keccak256(abi.encodePacked(abi.encode(data[i])));
        }

        return hashedData;
    }
}
