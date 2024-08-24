// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import {Script,console} from "forge-std/Script.sol";
import {ConcentratedLiquidityDEX} from  "../src/ConcentratedLiquidityDexx.sol";
import {EduMarketplace} from "../src/EduMarketplace.sol";

contract DeployEduToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ACCOUNT_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        ConcentratedLiquidityDEX dex = new ConcentratedLiquidityDEX();
        EduMarketplace marketplace = new EduMarketplace();
        vm.stopBroadcast();
        console.log("ConcentratedLiquidityDEX deployed at:", address(dex));
        console.log("EduMarketplace deployed at:", address(marketplace));
    }
}
