// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Profile.sol";
import "../src/interfaces/IProfile.sol";
import "../src/TokenAuthorizer.sol";
import "../src/NftAuthorizer.sol";
import "../src/MoneyBagsAuthorizer.sol";
import "../src/DummyAuthorizer.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ProfileTest is Test {
    using Strings for uint256;
   
    uint256 polygon;

    Profile public profile;
    MoneyBagsAuthorizer public moneyBags;
    DummyAuthorizer public dummyAuth;
    address[] public list;


    address public profile1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    address public cam = 0x9CF1f938AD0AABddff1Cf372eF8f0793056D0ac9;
    address public ethdevn = 0x6C84D94E7c868e55AAabc4a5E06bdFC90EF3Bc72;

   function setUp() public {
        string memory POLYGON_RPC_URL = vm.envString("POLYGON_RPC_URL");
        polygon = vm.createSelectFork(POLYGON_RPC_URL);

        vm.prank(cam);
        profile = new Profile("profile");
        moneyBags = new MoneyBagsAuthorizer();
        dummyAuth = new DummyAuthorizer();
   }

    function testAuthorizerAddition() public {
        vm.prank(cam);
        profile.addAuthorizer(address(dummyAuth));

        vm.prank(cam);
        profile.removeAuthorizer(address(dummyAuth));
    }

    function testAttest() public {

        vm.prank(cam);
        profile.addAuthorizer(address(dummyAuth));

        vm.prank(cam);
        profile.addPost(address(dummyAuth), "Hello World");
        
        console.log(vm.toString(dummyAuth.latestValidatedHash(address(profile))));
    }

    function testMoneyBagsValidator() public {

        vm.prank(cam);
        profile.addAuthorizer(address(moneyBags));

        console.log(uint256(moneyBags.getLatestPrice()).toString());
        uint256 temp = address(cam).balance;
        console.log(vm.toString(temp));
        console.log(vm.toString(uint256(moneyBags.getLatestPrice()) * temp));
        console.log(vm.toString(uint256(moneyBags.getLatestPrice()) * temp / 1 ether));


        vm.prank(cam);
        profile.addPost(address(moneyBags), "Hello World");

        console.log(vm.toString(moneyBags.latestValidatedHash(address(profile))));
    }

    function testHashes() public {

        vm.prank(cam);
        profile.addAuthorizer(address(dummyAuth));

        // console.log(uint256(ek.getLatestPrice()).toString());
        // uint256 temp = address(cam).balance;
        // console.log(vm.toString(temp));
        // console.log(vm.toString(uint256(ek.getLatestPrice()) * temp));

        vm.prank(cam);
        profile.addPost(address(dummyAuth), "Hello World");
        bytes32 hash1 = dummyAuth.latestValidatedHash(address(profile));
        console.log(vm.toString(hash1));

        vm.prank(cam);
        profile.addPost(address(dummyAuth), "A brave new world");
        bytes32 hash2 = dummyAuth.latestValidatedHash(address(profile));
        console.log(vm.toString(hash2));

        vm.prank(cam);
        profile.addPost(address(dummyAuth), "world on fire");
        bytes32 hash3 = dummyAuth.latestValidatedHash(address(profile));
        console.log(vm.toString(hash3));

        vm.prank(cam);
        profile.deletePost(address(dummyAuth), 1);


        IProfile.Attestation memory deletedAttest = profile.postByAuthorizerAndIndex(address(dummyAuth), 1);
        assertEq(deletedAttest.sender, address(profile)); //TODO really, the sender and owner should be diffrent so this assert makes sense.. should assert it is the *owner*
        console.log(deletedAttest.message);
        assertEq(deletedAttest.message, "");

        // ensure that the hash does not change when the message is deleted.
        // since the message is no longer available, anyone recomputing the hash will get a
        // different result, and flag as suspicious.
        assertEq(dummyAuth.latestValidatedHash(address(profile)), hash3);
    }

    function testGetAttestation() public {
        vm.prank(cam);
        profile.addAuthorizer(address(dummyAuth));

        vm.prank(cam);
        profile.addPost(address(dummyAuth), "Hello World");

        IProfile.Attestation memory attest = profile.postByAuthorizerAndIndex(address(dummyAuth), 0);


        assertEq(attest.sender, cam);
        assertEq(attest.message, "Hello World");
    }

    function testGetAuthorizers() public {
        vm.prank(cam);
        profile.addAuthorizer(address(moneyBags));
        vm.prank(cam);
        profile.addAuthorizer(address(dummyAuth));
        vm.prank(profile1);
        list = profile.getAuthorizerList();

        assertEq(address(moneyBags), list[0]);
        assertEq(address(dummyAuth), list[1]);

        for(uint i=0; i < list.length; i++) {
            console.log(vm.toString(list[i]));
        }
    }
}
