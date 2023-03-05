// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Profile.sol";
import "../src/MoneyBagsAuthorizer.sol";
import "../src/NftAuthorizer.sol";
import "../src/TokenAuthorizer.sol";
import "../src/DummyAuthorizer.sol";

contract ProfileScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // deploy some contracts for funsies.
        Profile profile = new Profile("nobody");
        MoneyBagsAuthorizer moneyBags = new MoneyBagsAuthorizer();
        // NftAuthorizer ethDenverAuth = new NftAuthorizer(0x6C84D94E7c868e55AAabc4a5E06bdFC90EF3Bc72);
        DummyAuthorizer dummy = new DummyAuthorizer();
        TokenAuthorizer sporkAuth = new TokenAuthorizer(0x9CA6a77C8B38159fd2dA9Bd25bc3E259C33F5E39, 1);

        vm.stopBroadcast();
    }
}
