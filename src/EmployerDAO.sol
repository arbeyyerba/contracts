// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IAuthorize.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract EmployerDAO is IAuthorize {

    struct AuthorizerParams {
        bool doAuth;
        address owner;
    }

    AuthorizerParams public params;
    AggregatorV3Interface public priceFeed;

    address[] public employees;

    // IAuthorize

    constructor(bool _doAuth) {
        params.doAuth = _doAuth;
        params.owner = msg.sender;

        //Polygon Testnet
        priceFeed = AggregatorV3Interface(
            0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada //matic MATIC/USD .5% 120s 8 decimals
        );

        employees.push(msg.sender);
    }

    function isApprovedToSend(address profile) external view returns (bool) {
        require(profile == params.owner);

        //Authorizer requires profile to have a certain amount of USD value in the wallet
        //math: 8+18-18 = 8 decimals, checks if address has > 1 USD
        require(uint256(getLatestPrice()) * profile.balance / 1 ether > 1e8, "Not enough tokens");

        //Authorizer requires an attester to be an employee
        require(isEmployee(profile));

        

        return params.doAuth;
    }

    function isApprovedToReceive(address profile) external view returns (bool) {
        require(isEmployee(profile));
        return true;
    }

    function addEmployee(address employee) external {
        employees.push(employee);
    }

    function isEmployee(address employee) internal view returns (bool) {
        for (uint i = 0; i < employees.length; i++) {
            if(employee == employees[i]) {
                return true;
            }
        }
        return false;
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