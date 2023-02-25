// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Profile.sol";
import "../src/mocks/Authorizer.sol";

contract TestState is Script {
    function setUp() public {}

    function run() public {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);

        // deploy some contracts for funsies.
        Profile profile = new Profile();
        Authorizer alwaysAuthorizer = new Authorizer(true);
        Authorizer neverAuthorizer = new Authorizer(false);

        // vm.stopBroadcast();
    }
}