// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Bank} from "../src/bank.sol";

contract DeployBank is Script {
    function run() public {
        uint256 privateKey = vm.envUint("NFT_PRIVATE_KEY");
        address deployer = vm.addr(privateKey);

        // 检查并打印余额
        console.log("Deployer Balance", deployer.balance);

        vm.startBroadcast(privateKey);
        new Bank();
        vm.stopBroadcast();
    }
}
