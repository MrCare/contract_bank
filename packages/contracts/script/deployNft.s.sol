// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {CarNFT} from "../src/nft.sol";

contract DeployNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("NFT_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // 从环境变量获取 IPFS 哈希，如果没有则使用默认值
        string memory ipfsHash = vm.envOr("IPFS_HASH", string("bafybeido6cgqfklqz3rkogsuji2jqvbw5pct2dprxvolkpk7y5qwdetttm"));
        
        console.log("==========================================");
        console.log("Deploying CarNFT Contract");
        console.log("==========================================");
        console.log("Deployer address:", deployer);
        console.log("Deployer balance:", deployer.balance);
        console.log("IPFS Hash:", ipfsHash);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 部署 NFT 合约
        CarNFT nft = new CarNFT(ipfsHash);
        
        vm.stopBroadcast();
        
        // 输出部署信息
        console.log("==========================================");
        console.log("NFT Contract deployed successfully!");
        console.log("==========================================");
        console.log("Contract address:", address(nft));
        console.log("Contract name:", nft.name());
        console.log("Contract symbol:", nft.symbol());
        console.log("Contract owner:", nft.owner());
        console.log("IPFS Hash:", nft.getIPFSHash());
        console.log("==========================================");
        
        // // 验证 tokenURI 格式（需要先铸造一个 NFT）
        // console.log("Testing tokenURI format...");
        // nft.mint(deployer, 1); // 铸造 CBR400R NFT
        // console.log("TokenURI(1):", nft.tokenURI(1));
        // console.log("==========================================");
    }
}
