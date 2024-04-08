//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Script} from "./../lib/openzeppelin-contracts/lib/forge-std/src/Script.sol";
import {UDGenesisNFT} from "../src/UDNFT.sol";

contract DeployUDGenesisNFT is Script {
    UDGenesisNFT genesisNFT;
    bytes32 public merkleRoot =
        0x46a87fad77d0a97166a8020104250bb8f9378985b0980daf62a7ab81cf029de5;

    function run() public returns (UDGenesisNFT) {
        vm.startBroadcast();
        genesisNFT = new UDGenesisNFT(merkleRoot);
        vm.stopBroadcast();
        return genesisNFT;
    }
}

// Start verifying contract `0xCb6cbA30529A8c15DF803c4666a477779C86dAC6` deployed on base-sepolia

// Submitting verification for [src/UDNFT.sol:UDGenesisNFT] 0xCb6cbA30529A8c15DF803c4666a477779C86dAC6.
// Submitted contract for verification:
//         Response: `OK`
//         GUID: `apyfhrfd5dhendbb6cusbhhykger8svqdrxvhdjpk9bpttthnz`
//         URL: https://sepolia.basescan.org/address/0xcb6cba30529a8c15df803c4666a477779c86dac6
// Contract verification status:
// Response: `NOTOK`
// Details: `Pending in queue`
// Contract verification status:
// Response: `OK`
// Details: `Pass - Verified`
// Contract successfully verified
