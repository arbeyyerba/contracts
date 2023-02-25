// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Profile.sol";
import "../src/mocks/Authorizer.sol";

contract ProfileTest is Test {
   
    Profile public eg;
    Authorizer public ek;

    address public profile1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

   function setUp() public {
        eg = new Profile();
        ek = new Authorizer(true);
   }

    function testAuthorizerAddition() public {
        eg.addAuthorizer(address(ek));
        console.log(eg.authorizedContract(address(ek)));

        eg.removeAuthorizer(address(ek));
        console.log(eg.authorizedContract(address(ek)));
    }

    function testAttest() public {
        vm.expectRevert();
        eg.attest(address(ek), "Hello World");

        eg.addAuthorizer(address(ek));
        eg.attest(address(ek), "Hello World");

        //console.log(string(bytes(abi.decode(eg.attestations(address(ek), 0), (string)))));
        //assertEq(eg.viewAttestation(address(ek), 0), "Hello World");
    }

    //logs not returning data
    function testContest() public {
        testAttest();
        eg.contest(0, "Because I am");
        console.log(eg.contestations(0));
    }

    function testViewAttestation() public {
        eg.addAuthorizer(address(ek));
        eg.attest(address(ek), "Hello World");
        //console.log(string(eg.attestations(msg.sender, 0)));
        //console.log(eg.viewAttestation(address(ek), 0), "Hello World");
    }
}
