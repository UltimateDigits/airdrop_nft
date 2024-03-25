// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract UDGenesisNFT is ERC1155, IERC2981, Ownable {
    //Error
    error UDNFT__MinterAlreadyOwnsNFT();
    error UDNFT__TokenIDNonExistent();
    error UDNFT__InvalidCaller();
    error UDNFT__CantSetToZeroAddress();
    error UDNFT__InvalidTreasuryAddress();
    error UDNFT__WithdrawFailed();
    error UDNFT__InvalidTokenID();

    uint256 constant MAX_MINT_PER_ADDRESS = 1;
    uint256 constant DENO = 1000;

    uint256 public tokenId;
    uint256 public royalty;
    address public i_treasuryAddress =
        0xdDD293F635f2793E418Ad5Fd5044c1A49C2EF84D;

    mapping(uint256 => string) public idToTokenURI;

    string public name = "Ultimate Points Genesis NFT";
    string public symbol = "UGNFT";
    string tokenUri =
        "https://cloudflare-ipfs.com/ipfs/bafybeiaeynocgow4bcfws4ye44z3vqfy7slhj64i4krpok6vjh5bdnpo6m/NFT1.json";

    modifier isEOA() {
        if (tx.origin != msg.sender) revert UDNFT__InvalidCaller();
        _;
    }

    constructor() ERC1155(tokenUri) Ownable(msg.sender) {
        royalty = 100;
        idToTokenURI[tokenId] = tokenUri;
    }

    function mintNFT() external isEOA {
        if (balanceOf(_msgSender(), tokenId) >= MAX_MINT_PER_ADDRESS)
            revert UDNFT__MinterAlreadyOwnsNFT();

        _mint(_msgSender(), tokenId, 1, "");
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
        idToTokenURI[tokenId] = uri;
    }
}
