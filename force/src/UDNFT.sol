// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract UDGenesisNFT is ERC1155, IERC2981, Ownable {
    //Error
    error UDNFT__InvalidCaller();
    error UDNFT__AirDropFailed();
    error UDNFT__InvalidAmount();
    error UDNFT__InvalidAddress();
    error UDNFT__InvalidTokenID();
    error UDNFT__WithdrawFailed();
    error UDNFT_InvalidMerkleProof();
    error UDNFT__TokenIDNonExistent();
    error UDNFT__MinterAlreadyOwnsNFT();
    error UDNFT__CantSetToZeroAddress();
    error UDNFT__InvalidTreasuryAddress();
    error UDNFT__NullMerkleRootNotAllowed();

    uint256 constant MAX_MINT_PER_ADDRESS = 1;
    uint256 constant DENO = 1000;

    uint256 public constant TOKEN_ID = 0;
    uint256 public royalty;
    address public i_treasuryAddress =
        0xdDD293F635f2793E418Ad5Fd5044c1A49C2EF84D;
    bytes32 public i_merkleRoot;

    event AirDropSend(address sender, address receiver, uint256 tokenAmt);

    string public name = "Ultimate Points Genesis NFT";
    string public symbol = "UGNFT";
    string tokenUri =
        "https://cloudflare-ipfs.com/ipfs/bafybeiaeynocgow4bcfws4ye44z3vqfy7slhj64i4krpok6vjh5bdnpo6m/NFT1.json";

    constructor(bytes32 _merkleRoot) ERC1155(tokenUri) Ownable(msg.sender) {
        i_merkleRoot = _merkleRoot;
        royalty = 100;
    }

    //AirDrop
    function claimAirdrop(
        bytes32[] calldata merkleProof,
        address user
    ) public onlyOwner {
        uint256 _tokenAmount = 1;
        if (balanceOf(user, TOKEN_ID) >= MAX_MINT_PER_ADDRESS)
            revert UDNFT__MinterAlreadyOwnsNFT();
        if (address(user) == address(0)) revert UDNFT__InvalidAddress();
        if (_tokenAmount <= 0) revert UDNFT__InvalidAmount();

        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(user, _tokenAmount)))
        );
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf))
            revert UDNFT_InvalidMerkleProof();

        _mint(user, TOKEN_ID, _tokenAmount, "");

        emit AirDropSend(address(this), user, _tokenAmount);
    }

    function royaltyInfo(
        uint256 _tokenId,
        uint256 salePrice
    ) external view override returns (address, uint256) {
        if (_tokenId != 0) revert UDNFT__InvalidTokenID();
        uint256 royaltyAmount = (salePrice * royalty) / DENO;
        return (i_treasuryAddress, royaltyAmount);
    }

    function setTreasuryAddress(address _addr) external onlyOwner {
        if (_addr == address(0x0)) revert UDNFT__CantSetToZeroAddress();
        i_treasuryAddress = _addr;
    }

    function setMerkleRoot(bytes32 _newMerkleRoot) public onlyOwner {
        if (_newMerkleRoot.length != i_merkleRoot.length)
            revert UDNFT__NullMerkleRootNotAllowed();
        i_merkleRoot = _newMerkleRoot;
    }

    function withdraw() external onlyOwner {
        if (i_treasuryAddress == address(0x0))
            revert UDNFT__InvalidTreasuryAddress();
        (bool success, ) = i_treasuryAddress.call{value: address(this).balance}(
            ""
        );
        if (!success) revert UDNFT__WithdrawFailed();
    }

    function setMetadataURI(string memory uri) public onlyOwner {
        _setURI(uri);
    }
}
