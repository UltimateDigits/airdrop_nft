//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Script} from "./../lib/openzeppelin-contracts/lib/forge-std/src/Script.sol";
import {UDGenesisNFT} from "../src/UDNFT.sol";

contract DeployUDGenesisNFT is Script {
    UDGenesisNFT genesisNFT;
    string public _tokenURI =
        "ipfs://bafybeiagmdgu2ixhoc4ut64373p65sv3nejarb6jlmwbr2kre55he5ejiy/NFT1.json";

    function run() public returns (UDGenesisNFT) {
        vm.startBroadcast();
        genesisNFT = new UDGenesisNFT(
            "UDigits-Genesis-NFT",
            "UGNFT",
            0xE6F3889C8EbB361Fa914Ee78fa4e55b1BBed3A96
        );
        vm.stopBroadcast();
        return genesisNFT;
    }
}
