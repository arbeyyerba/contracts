// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Profile.sol";
import "../src/SporkAuthorizer.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ProfileTest is Test {
    using Strings for uint256;
   
    Profile public eg;
    SporkAuthorizer public ek;

    address public profile1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    address public Austin = 0x096f6A2b185d63D942750A2D961f7762401cbA17;

   function setUp() public {
        console.log(msg.sender);
        vm.prank(Austin);
        eg = new Profile();
        console.log(eg.owner());

        ek = new SporkAuthorizer();
   }

    function testAuthorizerAddition() public {
        vm.startPrank(Austin);
        eg.addAuthorizer(address(ek));
        console.log(eg.authorizedContract(address(ek)));

        eg.removeAuthorizer(address(ek));
        console.log(eg.authorizedContract(address(ek)));
    }

    function testAttest() public {

        vm.startPrank(Austin);
        //vm.expectRevert();
        //eg.attest(address(ek), "Hello World");

        eg.addAuthorizer(address(ek));
        vm.stopPrank();

        console.log(uint256(ek.getLatestPrice()).toString());
        eg.attest(address(ek), "Hello World");

        //console.log(string(bytes(abi.decode(eg.attestations(address(ek), 0), (string)))));
        //assertEq(eg.viewAttestation(address(ek), 0), "Hello World");
    }

    //logs not returning data
    function testContest() public {
        testAttest();
        eg.contest(address(msg.sender), 0, "Because I am");
        console.log(eg.contestations(msg.sender, 0));
    }

    function testViewAttestation() public {
        vm.startPrank(Austin);
        eg.addAuthorizer(address(ek));
        eg.attest(address(ek), "Hello World");
        console.log(eg.attestations(msg.sender, 0));
        //console.log(eg.viewAttestation(address(ek), 0), "Hello World");
    }
}
