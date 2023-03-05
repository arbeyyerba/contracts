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
import "@lens/contracts/interfaces/ILensHub.sol";
import "@lens/contracts/interfaces/ICollectNFT.sol";

contract ProfileTest is Test {
    using Strings for uint256;
   
    uint256 polygon;

    address public cam = 0x9CF1f938AD0AABddff1Cf372eF8f0793056D0ac9;
    address public lensHub = 0xDb46d1Dc155634FbC732f92E853b10B288AD5a1d;
    address public ethdevn = 0x6C84D94E7c868e55AAabc4a5E06bdFC90EF3Bc72;
    
    uint256 camId;
    address camFollowNFT;
    address camCollectNFT = 0x2172758eBb894c43E0BE01e37D065118317D7eeC;

   function setUp() public {
        string memory POLYGON_RPC_URL = vm.envString("POLYGON_RPC_URL");
        polygon = vm.createSelectFork(POLYGON_RPC_URL);
        camId = ILensHub(lensHub).defaultProfile(cam);
        camFollowNFT = ILensHub(lensHub).getFollowNFT(camId);
   }

   function testPost() public {
        (uint profileId, uint pubId) = ICollectNFT(camCollectNFT).getSourcePublicationPointer();
        console.log(vm.toString(profileId));
        console.log(vm.toString(pubId));
   }
}