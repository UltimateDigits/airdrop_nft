// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "./../lib/openzeppelin-contracts/lib/forge-std/src/Test.sol";
import {UDGenesisNFT} from "../src/UDNFT.sol";

contract UDGenesisNFTTest is Test {
    UDGenesisNFT public udGenesisNFT;
    address public owner;
    address public minter;
    address public anotherAccount;

    function setUp() public {
        owner = makeAddr("owner");
        minter = makeAddr("minter");
        anotherAccount = makeAddr("another");

        udGenesisNFT = new UDGenesisNFT();
        // vm.startPrank(owner);
        // udGenesisNFT.transferOwnership(owner);
        // vm.stopPrank();
    }

    function testConstructor() public {
        assertEq(udGenesisNFT.name(), "Ultimate Digits Genesis NFT");
        assertEq(udGenesisNFT.symbol(), "UGNFT");
        assertEq(udGenesisNFT.royalty(), 100);
        assertEq(
            udGenesisNFT.i_treasuryAddress(),
            0xE6F3889C8EbB361Fa914Ee78fa4e55b1BBed3A96
        );
    }

    function testMintNFT() public {
        vm.startPrank(minter);
        vm.expectRevert(UDGenesisNFT.UDNFT__InvalidCaller.selector);
        udGenesisNFT.mintNFT();
        assertEq(udGenesisNFT.balanceOf(minter, 0), 0);
        vm.stopPrank();
    }

    function testInvalidCallerMintNFT() public {
        vm.prank(anotherAccount, anotherAccount);
        vm.expectRevert(UDGenesisNFT.UDNFT__InvalidCaller.selector);
        udGenesisNFT.mintNFT();
    }

    function testRoyaltyInfo() public {
        (address receiver, uint256 royaltyAmount) = udGenesisNFT.royaltyInfo(
            0,
            100 ether
        );
        assertEq(receiver, udGenesisNFT.i_treasuryAddress());
        assertEq(royaltyAmount, 10 ether);

        vm.expectRevert(UDGenesisNFT.UDNFT__InvalidTokenID.selector);
        udGenesisNFT.royaltyInfo(1, 100 ether);
    }

    function testSetTreasuryAddress() public {
        address newTreasury = makeAddr("newTreasury");

        udGenesisNFT.setTreasuryAddress(newTreasury);
        assertEq(udGenesisNFT.i_treasuryAddress(), newTreasury);

        vm.expectRevert(UDGenesisNFT.UDNFT__CantSetToZeroAddress.selector);
        udGenesisNFT.setTreasuryAddress(address(0));
    }

    function testWithdraw() public {
        vm.deal(address(udGenesisNFT), 1 ether);
        udGenesisNFT.withdraw();
        assertEq(address(udGenesisNFT).balance, 0);
    }

    function testSetURI() public {
        uint256 tokenId = 1;
        string memory newURI = "https://example.com/metadata";

        udGenesisNFT.setMetadataURI(newURI);
        assertEq(udGenesisNFT.idToTokenURI(tokenId), newURI);
    }
}
