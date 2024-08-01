// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import "forge-std/Script.sol";
import {NFT} from "src/NFT.sol";

contract DeployScript is Script {
    function run() public {
        address owner = vm.envAddress("OWNER_ADDRESS");
        vm.startBroadcast();

        new NFT(owner);

        vm.stopBroadcast();
    }
}
