// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MyToken} from "../src/token.sol";

contract DeployToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("NFT_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deployer address:", deployer);
        console.log("Deployer balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);
        
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
        console.log("Deployer balance:", token.balanceOf(deployer));
        console.log("==========================================");
    }
}
