// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "./../lib/openzeppelin-contracts/lib/forge-std/src/Test.sol";
import {UDGenesisNFT} from "../src/UDNFT.sol";

contract UDGenesisNFTTest is Test {
    UDGenesisNFT public udGenesisNFT;
    address public owner;
    address public minter;
    address public anotherAccount;
    bytes32 public merkleRoot =
        0x46a87fad77d0a97166a8020104250bb8f9378985b0980daf62a7ab81cf029de5;

    uint256 public constant TOKEN_ID = 0;

    function setUp() public {
        owner = makeAddr("owner");
        minter = makeAddr("minter");
        anotherAccount = makeAddr("another");

        udGenesisNFT = new UDGenesisNFT(merkleRoot);
    }

    function testConstructor() public {
        assertEq(udGenesisNFT.name(), "Ultimate Points Genesis NFT");
        assertEq(udGenesisNFT.symbol(), "UGNFT");
        assertEq(udGenesisNFT.royalty(), 100);
        assertEq(
            udGenesisNFT.i_treasuryAddress(),
            0xdDD293F635f2793E418Ad5Fd5044c1A49C2EF84D
        );
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
        assertEq(udGenesisNFT.uri(tokenId), newURI);
    }

    function testClaimAirdrop() public {
        bytes32[] memory minterProof = new bytes32[](2);
        minterProof[
            0
        ] = 0x46a30c59589466d364055f3cf20d5f8c1836d66bdc74358bad35ef6a7480937f;
        minterProof[
            1
        ] = 0x6db4166d9cf3646f49155a27f2583f3cefe582a375e5b369a2e71ccf3f1eec4a;

        udGenesisNFT.claimAirdrop(minterProof, minter);

        assertEq(udGenesisNFT.balanceOf(minter, TOKEN_ID), 1);
    }

    function testClaimAirdropWithInvalidProof() public {
        bytes32[] memory invalidProof = new bytes32[](2);
        invalidProof[
            0
        ] = 0x46a30c59589466d364055f4cf20d5f8c1836d66bdc74358bad35ef6a7480937f; // Invalid proof hashes
        invalidProof[
            1
        ] = 0x6db4166d9cf3646f49155a27f2563f3cefe582a375e5b369a2e71ccf5f1eec4a;

        vm.expectRevert(UDGenesisNFT.UDNFT_InvalidMerkleProof.selector);
        udGenesisNFT.claimAirdrop(invalidProof, minter);

        assertEq(udGenesisNFT.balanceOf(minter, TOKEN_ID), 0);
    }

    function testClaimAirdropWithZeroAddress() public {
        bytes32[] memory minterProof = new bytes32[](2);
        minterProof[
            0
        ] = 0x46a30c59589466d364055f3cf20d5f8c1836d66bdc74358bad35ef6a7480937f;
        minterProof[
            1
        ] = 0x6db4166d9cf3646f49155a27f2583f3cefe582a375e5b369a2e71ccf3f1eec4a;

        vm.expectRevert(UDGenesisNFT.UDNFT__InvalidAddress.selector);
        udGenesisNFT.claimAirdrop(minterProof, address(0));
    }

    function testSetMerkleRootWithNonOwner() public {
        vm.prank(anotherAccount);
        vm.expectRevert();
        udGenesisNFT.setMerkleRoot(
            bytes32(
                0x6db4166d9cf3646f49155a27f2583f4cefe582a375e5b369a2e71ccf3f1eec4a
            )
        );
    }

    function testSetMerkleRoot() public {
        bytes32 newMerkleRoot = 0x46a87fad77d0a97166a1020104250bb8f9378985b0380daf62a7ab81cf029de5;

        udGenesisNFT.setMerkleRoot(newMerkleRoot);

        assertEq(udGenesisNFT.i_merkleRoot(), newMerkleRoot);
    }
}
