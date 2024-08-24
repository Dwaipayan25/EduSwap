// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import {Script,console} from "forge-std/Script.sol";
import {EduToken} from "../src/EduToken.sol";

contract DeployEduToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ACCOUNT_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        EduToken eduToken = new EduToken("EduToken", "EDU", 1000000 ether);
        vm.stopBroadcast();
        console.log("EduToken deployed at:", address(eduToken));
    }
}
