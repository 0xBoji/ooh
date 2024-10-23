// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/OOH_NFT.sol";

contract OOH_NFTTest is Test {
    OOH_NFT public oohNFT;
    address public owner;
    address public addr1;
    address public addr2;

    function setUp() public {
        owner = address(this);
        addr1 = address(0x1);
        addr2 = address(0x2);
        oohNFT = new OOH_NFT();
    }

    function testMinting() public {
        oohNFT.mint_OOH_NFT(addr1, "https://example.com/token1");
        assertEq(oohNFT.ownerOf(0), addr1);
    }

    function testBooking() public {
        oohNFT.mint_OOH_NFT(addr1, "https://example.com/token1");
        vm.prank(addr1);
        oohNFT.booking_OOH_NFT(addr2, addr1, "Booking context", 100, 0);
        string[] memory calendar = oohNFT.get_OOH_Calendar(addr1, 0);
        assertEq(calendar.length, 1);
        assertEq(calendar[0], "Booking context");
    }

    function testCancelling() public {
        oohNFT.mint_OOH_NFT(addr1, "https://example.com/token1");
        vm.prank(addr1);
        oohNFT.booking_OOH_NFT(addr2, addr1, "Booking context", 100, 0);
        vm.prank(addr2);
        oohNFT.cancel_OOH_NFT(addr2, 1, "Booking context", 0);
        string[] memory calendar = oohNFT.get_OOH_Calendar(addr1, 0);
        assertEq(calendar.length, 0);
    }
}