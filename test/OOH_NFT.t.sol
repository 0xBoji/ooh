// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/OOH_NFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";  

contract OOH_NFTTest is Test {
    OOH_NFT public oohNFT;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        oohNFT = new OOH_NFT();
    }

    function testMintOOHNFT() public {
        string memory uri = "ipfs://example";
        oohNFT.mint_OOH_NFT(user1, uri);

        assertEq(oohNFT.ownerOf(0), user1);
        assertEq(oohNFT.tokenURI(0), uri);
    }

    function testBookingOOHNFT() public {
        oohNFT.mint_OOH_NFT(user1, "ipfs://example");
        
        vm.prank(user1);
        oohNFT.booking_OOH_NFT(user2, user1, "Booking context", 100, 0);

        assertEq(oohNFT.get_OOH_Calendar(user1, 0)[0], "Booking context");
    }

    function testCancelOOHNFT() public {
        oohNFT.mint_OOH_NFT(user1, "ipfs://example");
        
        vm.prank(user1);
        oohNFT.booking_OOH_NFT(user2, user1, "Booking context", 100, 0);

        vm.prank(user2);
        oohNFT.cancel_OOH_NFT(user2, 1, "Booking context", 0);

        assertEq(oohNFT.get_OOH_Calendar(user1, 0).length, 0);
    }

    function testGetOOHContract() public {
        oohNFT.mint_OOH_NFT(user1, "ipfs://example");
        
        vm.prank(user1);
        oohNFT.booking_OOH_NFT(user2, user1, "Booking context", 100, 0);

        string memory context = oohNFT.get_OOH_Contract(user2, 1, 0);
        assertEq(context, "Booking context");
    }

    function testGetOOHCalendar() public {
        oohNFT.mint_OOH_NFT(user1, "ipfs://example");
        
        vm.prank(user1);
        oohNFT.booking_OOH_NFT(user2, user1, "Booking context", 100, 0);

        string[] memory calendar = oohNFT.get_OOH_Calendar(user1, 0);
        assertEq(calendar.length, 1);
        assertEq(calendar[0], "Booking context");
    }

    function testTransferFromBlocked() public {
        oohNFT.mint_OOH_NFT(user1, "ipfs://example");
        
        vm.prank(user1);
        vm.expectRevert("Err: token transfer is BLOCKED");
        oohNFT.transferFrom(user1, user2, 0);
    }

    function testGetOOHNFTs() public {
        oohNFT.mint_OOH_NFT(user1, "ipfs://example1");
        oohNFT.mint_OOH_NFT(user1, "ipfs://example2");

        uint256[] memory nfts = oohNFT.getOOH_NFTs(user1);
        assertEq(nfts.length, 2);
        assertEq(nfts[0], 0);
        assertEq(nfts[1], 1);
    }

    function testBurnOOHNFT() public {
        oohNFT.mint_OOH_NFT(user1, "ipfs://example");
        
        oohNFT.burn_OOH_NFT(user1, 0);
        
        vm.expectRevert();
        oohNFT.ownerOf(0);
    }

    function testBurnAllOOHNFTs() public {
        oohNFT.mint_OOH_NFT(user1, "ipfs://example1");
        oohNFT.mint_OOH_NFT(user1, "ipfs://example2");

        oohNFT.burn_All_OOH_NFTs(user1);

        vm.expectRevert();
        oohNFT.ownerOf(0);
        vm.expectRevert();
        oohNFT.ownerOf(1);
    }


    function testDirectBurnNotAllowed() public {
        oohNFT.mint_OOH_NFT(user1, "ipfs://example");
        
        vm.prank(user1);
        vm.expectRevert("Err: Direct burn not allowed");
        oohNFT.burn(0);
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        oohNFT.mint_OOH_NFT(user2, "ipfs://example");
    }

    function testOnlyOwnerCanBurn() public {
        oohNFT.mint_OOH_NFT(user1, "ipfs://example");

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        oohNFT.burn_OOH_NFT(user1, 0);
    }
}