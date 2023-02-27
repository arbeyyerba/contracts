// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Profile.sol";
import "../src/SporkAuthorizer.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ProfileTest is Test {
    using Strings for uint256;
   
    uint256 polygon;

    Profile public eg;
    SporkAuthorizer public ek;
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
   }

    function testAuthorizerAddition() public {
        vm.prank(cam);
        eg.addAuthorizer(address(ek));
        //console.log(eg.authorizedContract(address(ek)));

        vm.prank(cam);
        eg.removeAuthorizer(address(ek));
        //console.log(eg.authorizedContract(address(ek)));
    }

    function testAttest() public {

        vm.prank(cam);
        eg.addAuthorizer(address(ek));

        console.log(uint256(ek.getLatestPrice()).toString());
        uint256 temp = address(cam).balance;
        console.log(vm.toString(temp));
        console.log(vm.toString(uint256(ek.getLatestPrice()) * temp));

        vm.prank(cam);
        eg.attest(address(ek), "Hello World");
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
        eg.addAuthorizer(address(ek));

        vm.prank(cam);
        eg.attest(address(ek), "Hello World");

        console.log(eg.getAttestation(cam, 0));
    }

    function testGetAuthorizers() public {
        list.push(profile1);
        list.push(cam);
        list.push(ethdevn);
        for(uint i=0; i < list.length; i++) {
            console.log(vm.toString(list[i]));
        }
    }
}
