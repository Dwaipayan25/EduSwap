// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import {Script,console} from "forge-std/Script.sol";
import {ConcentratedLiquidityDEX} from  "../src/ConcentratedLiquidityDexx.sol";

contract DeployDex is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ACCOUNT_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        ConcentratedLiquidityDEX dex = new ConcentratedLiquidityDEX();
        vm.stopBroadcast();
        console.log("ConcentratedLiquidityDEX deployed at:", address(dex));
    }
}
