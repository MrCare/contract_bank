// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CarNFT} from "src/nft.sol";
import {MyToken} from "src/token.sol";
import {NFTMarket} from "src/nftMarket.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTMarketTest is Test, IERC721Receiver {
    CarNFT public nft;
    MyToken public token;
    NFTMarket public market;

    address public owner;
    address public user1;
    address public user2;
    address public user3;

    string constant IPFS_HASH = "QmYourIPFSHashHere";
    uint256 constant INITIAL_SUPPLY = 100 * 10 ** 18;
    uint256 constant NFT_PRICE = 10 * 10 ** 18; // 10 CTK

    function setUp() public {
        // 设置测试地址
        owner = address(this);
        user1 = vm.addr(1);
        user2 = vm.addr(2);
        user3 = vm.addr(3);

        // 部署合约
        nft = new CarNFT(IPFS_HASH);
        token = new MyToken();
        market = new NFTMarket(address(nft), address(token));

        // 给用户分发代币
        token.transfer(user1, 30 * 10 ** 18);
        token.transfer(user2, 20 * 10 ** 18);
        token.transfer(user3, 15 * 10 ** 18);

        // 铸造一些NFT
        nft.mint(owner, 1);
        nft.mint(owner, 2);
        nft.mint(owner, 3);

        // 授权市场合约操作NFT
        nft.setApprovalForAll(address(market), true); // 提前授权！
    }
    // 实现 IERC721Receiver 接口

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    // ============ 基础功能测试 ============

    function test_marketBasicInfo() public view {
        console.log(unicode"测试市场基础信息");
        assertEq(address(market.nftContract()), address(nft));
        assertEq(address(market.tokenContract()), address(token));
        assertEq(market.owner(), owner);
        assertEq(market.nftCount(), 0);
    }

    function test_listNFT() public {
        console.log(unicode"测试上架NFT");

        // 上架NFT
        market.list(1, NFT_PRICE);

        // 检查结果
        assertEq(market.nftCount(), 1);

        (uint256 tokenId, uint256 price, address nftOwner, bool isListed) = market.listedNfts(0);
        assertEq(tokenId, 1);
        assertEq(price, NFT_PRICE);
        assertEq(nftOwner, owner);
        assertTrue(isListed);
    }

    function test_listMultipleNFTs() public {
        console.log(unicode"测试上架多个NFT");

        // 上架多个NFT
        market.list(1, NFT_PRICE);
        market.list(2, NFT_PRICE * 2);
        market.list(3, NFT_PRICE * 3);

        // 检查结果
        assertEq(market.nftCount(), 3);

        // 检查第一个NFT
        (uint256 tokenId1, uint256 price1,,) = market.listedNfts(0);
        assertEq(tokenId1, 1);
        assertEq(price1, NFT_PRICE);

        // 检查第二个NFT
        (uint256 tokenId2, uint256 price2,,) = market.listedNfts(1);
        assertEq(tokenId2, 2);
        assertEq(price2, NFT_PRICE * 2);

        // 检查第三个NFT
        (uint256 tokenId3, uint256 price3,,) = market.listedNfts(2);
        assertEq(tokenId3, 3);
        assertEq(price3, NFT_PRICE * 3);
    }

    function test_buyNFTNormalWay() public {
        console.log(unicode"测试普通方式购买NFT");

        // 上架NFT
        market.list(1, NFT_PRICE);

        // user1购买NFT
        vm.startPrank(user1);
        token.approve(address(market), NFT_PRICE);

        // 记录购买前的状态
        uint256 user1TokensBefore = token.balanceOf(user1);
        uint256 ownerTokensBefore = token.balanceOf(owner);

        // 购买NFT
        market.buyNFT(0);
        vm.stopPrank();

        // 检查结果
        assertEq(nft.ownerOf(1), user1); // NFT转移给user1
        assertEq(token.balanceOf(user1), user1TokensBefore - NFT_PRICE); // user1支付代币
        assertEq(token.balanceOf(owner), ownerTokensBefore + NFT_PRICE); // owner收到代币
    }

    function test_buyNFTWithCallback() public {
        console.log(unicode"测试使用回调方式购买NFT");

        // 上架NFT
        market.list(1, NFT_PRICE);

        // user1使用transferWithCallback购买NFT
        vm.startPrank(user1);

        // 记录购买前的状态
        uint256 user1TokensBefore = token.balanceOf(user1);
        uint256 ownerTokensBefore = token.balanceOf(owner);

        // 编码listId作为data
        bytes memory data = abi.encode(uint256(0)); // listId = 0

        // 使用transferWithCallback购买
        token.transferWithCallback(address(market), NFT_PRICE, data);
        vm.stopPrank();

        // 检查结果
        assertEq(nft.ownerOf(1), user1); // NFT转移给user1
        assertEq(token.balanceOf(user1), user1TokensBefore - NFT_PRICE); // user1支付代币
        assertEq(token.balanceOf(owner), ownerTokensBefore + NFT_PRICE); // owner收到代币

        // 检查NFT状态已更新
        (,,, bool isListed) = market.listedNfts(0);
        assertFalse(isListed); // 应该标记为已售出
    }

    function test_buyMultipleNFTs() public {
        console.log(unicode"测试购买多个NFT");

        // 上架多个NFT
        market.list(1, NFT_PRICE);
        market.list(2, NFT_PRICE * 2);

        // user1购买第一个NFT
        vm.startPrank(user1);
        token.approve(address(market), NFT_PRICE);
        market.buyNFT(0);
        vm.stopPrank();

        // user2购买第二个NFT
        vm.startPrank(user2);
        token.approve(address(market), NFT_PRICE * 2);
        market.buyNFT(1);
        vm.stopPrank();

        // 检查结果
        assertEq(nft.ownerOf(1), user1);
        assertEq(nft.ownerOf(2), user2);
    }

    // ============ 错误情况测试 ============

    function test_onlyOwnerCanList() public {
        console.log(unicode"测试只有owner可以上架NFT");

        // 非owner尝试上架NFT应该失败
        vm.prank(user1);
        vm.expectRevert();
        market.list(1, NFT_PRICE);
    }

    function test_buyNFTInsufficientBalance() public {
        console.log(unicode"测试余额不足购买NFT");

        // 上架NFT
        market.list(1, NFT_PRICE);

        // user3余额不足(只有15个代币，需要10个)，但我们让他尝试购买价格更高的
        market.list(2, 20 * 10 ** 18); // 20个代币的价格

        vm.startPrank(user3);
        token.approve(address(market), 20 * 10 ** 18);
        vm.expectRevert(); // 应该失败，因为余额不足
        market.buyNFT(1);
        vm.stopPrank();
    }

    function test_buyNFTNotListed() public {
        console.log(unicode"测试购买未上架的NFT");

        // 上架NFT
        market.list(1, NFT_PRICE);

        // 先购买一次
        vm.startPrank(user1);
        bytes memory data = abi.encode(uint256(0));
        token.transferWithCallback(address(market), NFT_PRICE, data);
        vm.stopPrank();

        // 再次尝试购买相同的NFT应该失败
        vm.startPrank(user2);
        bytes memory data2 = abi.encode(uint256(0));
        vm.expectRevert("CallbackFailed()"); // 改为实际的错误
        token.transferWithCallback(address(market), NFT_PRICE, data2);
        vm.stopPrank();
    }

    function test_buyNFTInsufficientPayment() public {
        console.log(unicode"测试支付金额不足购买NFT");

        // 上架NFT
        market.list(1, NFT_PRICE);

        // user1尝试用不足的金额购买
        vm.startPrank(user1);
        bytes memory data = abi.encode(uint256(0));
        vm.expectRevert("CallbackFailed()"); // 改为实际的错误
        token.transferWithCallback(address(market), NFT_PRICE / 2, data);
        vm.stopPrank();
    }

    function test_tokensReceivedWithoutData() public {
        console.log(unicode"测试不带数据的代币接收");

        // user1向市场合约发送代币但不带购买数据，应该失败
        vm.prank(user1);
        vm.expectRevert("CallbackFailed()");
        token.transferWithCallback(address(market), NFT_PRICE, "");
    }

    function test_unauthorizedTokensReceived() public {
        console.log(unicode"测试未授权的代币接收调用");

        // 直接调用tokensReceived应该失败
        vm.prank(user1);
        vm.expectRevert("Only this contract can receive tokens");
        market.tokensReceived(user1, NFT_PRICE, abi.encode(uint256(0)));
    }
}
