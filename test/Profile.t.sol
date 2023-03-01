// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Profile.sol";
import "../src/interfaces/IProfile.sol";
import "../src/SporkAuthorizer.sol";
import "../src/DummyAuthorizer.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ProfileTest is Test {
    using Strings for uint256;
   
    uint256 polygon;

    Profile public eg;
    SporkAuthorizer public ek;
    DummyAuthorizer public eo;
    address[] public list;


    address public profile1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    address public cam = 0x9CF1f938AD0AABddff1Cf372eF8f0793056D0ac9;
    address public ethdevn = 0x6C84D94E7c868e55AAabc4a5E06bdFC90EF3Bc72;

   function setUp() public {
        string memory POLYGON_RPC_URL = vm.envString("POLYGON_RPC_URL");
        polygon = vm.createSelectFork(POLYGON_RPC_URL);

        vm.prank(cam);
        eg = new Profile();
        ek = new SporkAuthorizer();
        eo = new DummyAuthorizer();
   }

    function testAuthorizerAddition() public {
        vm.prank(cam);
        eg.addAuthorizer(address(eo));
        // console.log(eg.authorizedContract(address(ek)));

        vm.prank(cam);
        eg.removeAuthorizer(address(eo));
        // console.log(eg.authorizedContract(address(ek)));
    }

    function testAttest() public {

        vm.prank(cam);
        eg.addAuthorizer(address(eo));

        // console.log(uint256(ek.getLatestPrice()).toString());
        // uint256 temp = address(cam).balance;
        // console.log(vm.toString(temp));
        // console.log(vm.toString(uint256(ek.getLatestPrice()) * temp));

        vm.prank(cam);
        eg.attest(address(eo), "Hello World");
    }

    function testHashes() public {

        vm.prank(cam);
        eg.addAuthorizer(address(eo));

        // console.log(uint256(ek.getLatestPrice()).toString());
        // uint256 temp = address(cam).balance;
        // console.log(vm.toString(temp));
        // console.log(vm.toString(uint256(ek.getLatestPrice()) * temp));

        vm.prank(cam);
        eg.attest(address(eo), "Hello World");
        bytes32 hash1 = eo.getLatestValidatedHash(address(eg));

        vm.prank(cam);
        eg.attest(address(eo), "A brave new world");
        bytes32 hash2 = eo.getLatestValidatedHash(address(eg));

        vm.prank(cam);
        eg.attest(address(eo), "world on fire");
        bytes32 hash3 = eo.getLatestValidatedHash(address(eg));

        vm.prank(cam);
        eg.deleteAttestation(address(eo), 1);


        IProfile.Attestation memory deletedAttest = eg.getAttestation(address(eo), 1);
        assertEq(deletedAttest.sender, address(eg)); //TODO really, the sender and owner should be diffrent so this assert makes sense.. should assert it is the *owner*
        console.log(deletedAttest.message);
        assertEq(deletedAttest.message, "");

        // ensure that the hash does not change when the message is deleted.
        // since the message is no longer available, anyone recomputing the hash will get a
        // different result, and flag as suspicious.
        assertEq(eo.getLatestValidatedHash(address(eg)), hash3);
    }

    //logs not returning data
    function testGetContest() public {
        testAttest();

        vm.prank(cam);
        eg.contest(address(msg.sender), 0, "Because I am");

        console.log(eg.contestations(msg.sender, 0));
    }

    function testGetAttestation() public {
        vm.prank(cam);
        eg.addAuthorizer(address(eo));

        vm.prank(cam);
        eg.attest(address(eo), "Hello World");

        IProfile.Attestation memory attest = eg.getAttestation(address(eo), 0);


        assertEq(attest.sender, cam);
        assertEq(attest.message, "Hello World");
    }

    function testGetAuthorizers() public {
        vm.prank(cam);
        eg.addAuthorizer(address(ek));
        vm.prank(cam);
        eg.addAuthorizer(address(eo));
        vm.prank(profile1);
        list = eg.getAuthorizerList();

        assertEq(address(ek), list[0]);
        assertEq(address(eo), list[1]);

        for(uint i=0; i < list.length; i++) {
            console.log(vm.toString(list[i]));
        }
    }
}
