// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Bigbank} from "../src/bank.sol";

contract DeployBank is Script {
    function run() public {
        console.log("==========================================");
        console.log("Deploying Bank Contract");
        console.log("==========================================");
        
        // 使用 Foundry 钱包管理进行广播
        vm.startBroadcast();
        
        Bigbank bank = new Bigbank();
        
        vm.stopBroadcast();
        
        console.log("==========================================");
        console.log("Bank Contract deployed successfully!");
        console.log("==========================================");
        console.log("Contract address:", address(bank));
        console.log("==========================================");
    }
}
