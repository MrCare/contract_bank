// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CarNFT} from "src/nft.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract CarNFTTest is Test {
    CarNFT public nft;

    address public owner;
    address public user1;
    address public user2;
    address public user3;

    string constant IPFS_HASH = "QmYourIPFSHashHere";

    function setUp() public {
        // 设置测试地址
        owner = address(this);
        user1 = vm.addr(1);
        user2 = vm.addr(2);
        user3 = vm.addr(3);

        // 部署NFT合约
        nft = new CarNFT(IPFS_HASH);
    }

    // ============ 基础功能测试 ============

    function test_nftBasicInfo() public view {
        console.log(unicode"测试 NFT 基础信息");
        assertEq(nft.name(), "CarNFT");
        assertEq(nft.symbol(), "CFT");
        assertEq(nft.owner(), owner);
        assertEq(nft.getIPFSHash(), IPFS_HASH);
    }

    function test_mint() public {
        console.log(unicode"测试 NFT 铸造功能");

        // 铸造NFT给user1
        nft.mint(user1, 1);

        // 检查结果
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.ownerOf(1), user1);

        // 铸造多个NFT
        nft.mint(user2, 2);
        nft.mint(user3, 3);

        assertEq(nft.balanceOf(user2), 1);
        assertEq(nft.balanceOf(user3), 1);
        assertEq(nft.ownerOf(2), user2);
        assertEq(nft.ownerOf(3), user3);
    }

    function test_tokenURI() public {
        console.log(unicode"测试 tokenURI 功能");

        // 先铸造NFT
        nft.mint(user1, 1);

        // 检查tokenURI
        string memory expectedURI = string(abi.encodePacked("ipfs://", IPFS_HASH, "/1.json"));

        assertEq(nft.tokenURI(1), expectedURI);

        // 测试不同的tokenId
        nft.mint(user2, 10);
        string memory expectedURI10 = string(abi.encodePacked("ipfs://", IPFS_HASH, "/10.json"));
        assertEq(nft.tokenURI(10), expectedURI10);
    }

    function test_setIPFSHash() public {
        console.log(unicode"测试设置 IPFS 哈希");

        string memory newHash = "QmNewIPFSHashHere";

        // 只有owner可以设置
        nft.setIPFSHash(newHash);
        assertEq(nft.getIPFSHash(), newHash);

        // 非owner不能设置
        vm.prank(user1);
        vm.expectRevert();
        nft.setIPFSHash("QmUnauthorizedHash");
    }

    function test_tokenURIWithNewHash() public {
        console.log(unicode"测试更新IPFS哈希后的tokenURI");

        // 先铸造NFT
        nft.mint(user1, 1);

        // 更新IPFS哈希
        string memory newHash = "QmNewIPFSHashHere";
        nft.setIPFSHash(newHash);

        // 检查tokenURI是否更新
        string memory expectedURI = string(abi.encodePacked("ipfs://", newHash, "/1.json"));

        assertEq(nft.tokenURI(1), expectedURI);
    }

    // ============ 错误情况测试 ============

    function test_tokenURINonExistentToken() public {
        console.log(unicode"测试不存在的token的tokenURI");

        // 查询不存在的tokenId应该失败
        vm.expectRevert();
        nft.tokenURI(999);
    }

    function test_mintDuplicateTokenId() public {
        console.log(unicode"测试重复铸造相同tokenId");

        // 先铸造tokenId 1
        nft.mint(user1, 1);

        // 再次铸造相同tokenId应该失败
        vm.expectRevert();
        nft.mint(user2, 1);
    }

    function test_transferNFT() public {
        console.log(unicode"测试 NFT 转账功能");

        // 铸造NFT给user1
        nft.mint(user1, 1);

        // user1转账给user2
        vm.prank(user1);
        nft.transferFrom(user1, user2, 1);

        // 检查结果
        assertEq(nft.ownerOf(1), user2);
        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 1);
    }

    function test_approveAndTransfer() public {
        console.log(unicode"测试 NFT 授权和转账");

        // 铸造NFT给user1
        nft.mint(user1, 1);

        // user1授权给user2
        vm.prank(user1);
        nft.approve(user2, 1);

        // user2代表user1转账给user3
        vm.prank(user2);
        nft.transferFrom(user1, user3, 1);

        // 检查结果
        assertEq(nft.ownerOf(1), user3);
        assertEq(nft.getApproved(1), address(0)); // 授权应该被清除
    }
}
