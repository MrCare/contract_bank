// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Admin} from "../src/admin.sol";

contract DeployAdmin is Script {
    function run() public {
        console.log("==========================================");
        console.log("Deploying Admin Contract");
        console.log("==========================================");

        // 使用 Foundry 钱包管理进行广播
        vm.startBroadcast();

        Admin admin = new Admin();

        vm.stopBroadcast();

        console.log("==========================================");
        console.log("Admin Contract deployed successfully!");
        console.log("==========================================");
        console.log("Contract address:", address(admin));
        console.log("==========================================");
        console.log("Deployer address:", admin.owner());
    }
}
