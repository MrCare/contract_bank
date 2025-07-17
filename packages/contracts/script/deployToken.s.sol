// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MyToken} from "../src/token.sol";

contract DeployToken is Script {
    function run() external {
        console.log("==========================================");
        console.log("Deploying Token Contract");
        console.log("==========================================");

        // 使用 Foundry 钱包管理进行广播
        vm.startBroadcast();

        // 部署代币
        MyToken token = new MyToken();

        vm.stopBroadcast();

        // 输出部署信息
        console.log("==========================================");
        console.log("Token deployed successfully!");
        console.log("==========================================");
        console.log("Token address:", address(token));
        console.log("Token name:", token.name());
        console.log("Token symbol:", token.symbol());
        console.log("Token decimals:", token.decimals());
        console.log("Total supply:", token.totalSupply());
        console.log("==========================================");
    }
}
