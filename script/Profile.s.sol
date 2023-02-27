// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Profile.sol";
import "../src/SporkAuthorizer.sol";

contract ProfileScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // deploy some contracts for funsies.
        Profile profile = new Profile();
        SporkAuthorizer alwaysAuthorizer = new SporkAuthorizer();
        SporkAuthorizer neverAuthorizer = new SporkAuthorizer();

        

        vm.stopBroadcast();
    }
}