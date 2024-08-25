// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import {Script,console} from "forge-std/Script.sol";
import {EduToken} from "../src/EduToken.sol";

contract DeployEduToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ACCOUNT_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        EduToken eduToken1 = new EduToken("Token1", "T1", 1000000 ether);
        EduToken eduToken2 = new EduToken("Token2", "T2", 1000000 ether);
        vm.stopBroadcast();
        console.log("Token1 deployed at:", address(eduToken1)); //0xAfFd10577a50Bf40F1aBE96BEc7e322A00590Aa1
        console.log("Token2 deployed at:", address(eduToken2)); //0x03d2AC3Aeeb07BBa686756e422a1F749A06b0aA0
    }
}
