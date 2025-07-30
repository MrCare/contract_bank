// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CarNFT} from "../src/nft.sol";
import {MyToken} from "../src/token.sol";
import {NFTMarket, INFTMarketEvents, INFTMarketErrors} from "../src/nftMarket.sol";
import {NFTMarketAssembly} from "../src/nftMarketAssembly.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketTest is Test, IERC721Receiver, INFTMarketEvents, INFTMarketErrors {
    CarNFT public nft;
    MyToken public token;
    NFTMarket public market;
    NFTMarketAssembly public marketAssembly;

    address public owner;
    address public user1;
    address public user2;

    uint256 constant NFT_PRICE = 5 * 10 ** 18; // 5 CTK

    // Gas tracking
    struct GasReport {
        uint256 originalGas;
        uint256 optimizedGas;
        uint256 gasReduction;
        uint256 percentageReduction;
    }

    mapping(string => GasReport) public gasReports;

    function setUp() public {
        owner = address(this);
        user1 = vm.addr(1);
        user2 = vm.addr(2);

        // 部署合约
        nft = new CarNFT("QmYourIPFSHashHere");
        token = new MyToken();
        market = new NFTMarket(address(nft), address(token));
        marketAssembly = new NFTMarketAssembly(address(nft), address(token));

        // 分配代币
        token.transfer(user1, 40 * 10 ** 18);  // 40 CTK
        token.transfer(user2, 40 * 10 ** 18);  // 40 CTK
        
        // 铸造NFT
        nft.mint(owner, 1);
        nft.mint(owner, 2);
        nft.mint(owner, 3);
        nft.mint(owner, 4);
        nft.mint(owner, 5);
        nft.mint(owner, 6);

        // 授权市场合约操作NFT
        nft.setApprovalForAll(address(market), true);
        nft.setApprovalForAll(address(marketAssembly), true);
        
        console.log(unicode"Total Supply:", token.totalSupply());
        console.log(unicode"Owner token balance:", token.balanceOf(owner));
        console.log(unicode"User1 token balance:", token.balanceOf(user1));
        console.log(unicode"User2 token balance:", token.balanceOf(user2));
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function _calculateGasReport(string memory testName, uint256 originalGas, uint256 optimizedGas) internal {
        GasReport memory report;
        report.originalGas = originalGas;
        report.optimizedGas = optimizedGas;
        report.gasReduction = originalGas > optimizedGas ? originalGas - optimizedGas : 0;
        report.percentageReduction = originalGas > 0 ? (report.gasReduction * 100) / originalGas : 0;
        
        gasReports[testName] = report;
        
        console.log(unicode"=== Gas Report for %s ===", testName);
        console.log(unicode"Original Gas: %d", originalGas);
        console.log(unicode"Optimized Gas: %d", optimizedGas);
        console.log(unicode"Gas Reduction: %d", report.gasReduction);
        console.log(unicode"Percentage Reduction: %d%%", report.percentageReduction);
        console.log("================================");
    }

    // ============ 对比测试：上架NFT ============
    function test_ListNFT() public {
        console.log(unicode"测试上架NFT - 原版");
        
        uint256 gasBefore = gasleft();
        market.list(1, NFT_PRICE);
        uint256 originalGas = gasBefore - gasleft();
        
        NFTMarket.Listing memory listing = market.getListing(1);
        assertEq(listing.tokenId, 1);
        assertEq(listing.price, NFT_PRICE);
        assertEq(listing.seller, owner);
        assertTrue(listing.active);
        assertTrue(market.isListed(1));
        
        console.log(unicode"测试上架NFT - 优化版");
        
        gasBefore = gasleft();
        marketAssembly.list(2, NFT_PRICE);
        uint256 optimizedGas = gasBefore - gasleft();
        
        NFTMarketAssembly.Listing memory listingAssembly = marketAssembly.getListing(1);
        assertEq(listingAssembly.tokenId, 2);
        assertEq(listingAssembly.price, NFT_PRICE);
        assertEq(listingAssembly.seller, owner);
        assertTrue(listingAssembly.active);
        assertTrue(marketAssembly.isListed(2));
        
        _calculateGasReport("ListNFT", originalGas, optimizedGas);
    }

    // ============ 对比测试：购买NFT ============
    function test_BuyNFT() public {
        console.log(unicode"测试购买NFT - 准备阶段");
        
        // 准备原版合约
        market.list(1, NFT_PRICE);
        // 准备优化版合约
        marketAssembly.list(2, NFT_PRICE);
        
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 user1BalanceBefore = token.balanceOf(user1);
        
        console.log(unicode"测试购买NFT - 原版");
        vm.startPrank(user1);
        token.approve(address(market), NFT_PRICE);
        uint256 gasBefore = gasleft();
        market.buyNFT(1);
        uint256 originalGas = gasBefore - gasleft();
        vm.stopPrank();
        
        assertEq(nft.ownerOf(1), user1);
        assertEq(token.balanceOf(owner), ownerBalanceBefore + NFT_PRICE);
        assertEq(token.balanceOf(user1), user1BalanceBefore - NFT_PRICE);
        assertFalse(market.isListed(1));
        
        console.log(unicode"测试购买NFT - 优化版");
        vm.startPrank(user2);
        token.approve(address(marketAssembly), NFT_PRICE);
        gasBefore = gasleft();
        marketAssembly.buyNFT(1);
        uint256 optimizedGas = gasBefore - gasleft();
        vm.stopPrank();
        
        assertEq(nft.ownerOf(2), user2);
        assertFalse(marketAssembly.isListed(2));
        
        _calculateGasReport("BuyNFT", originalGas, optimizedGas);
    }

    // ============ 对比测试：查询函数 ============
    function test_IsListed() public {
        console.log(unicode"测试isListed查询 - 准备阶段");
        
        market.list(1, NFT_PRICE);
        marketAssembly.list(2, NFT_PRICE);
        
        console.log(unicode"测试isListed查询 - 原版");
        uint256 gasBefore = gasleft();
        bool result1 = market.isListed(1);
        uint256 originalGas = gasBefore - gasleft();
        assertTrue(result1);
        
        console.log(unicode"测试isListed查询 - 优化版");
        gasBefore = gasleft();
        bool result2 = marketAssembly.isListed(2);
        uint256 optimizedGas = gasBefore - gasleft();
        assertTrue(result2);
        
        _calculateGasReport("IsListed", originalGas, optimizedGas);
    }

    function test_GetListingByToken() public {
        console.log(unicode"测试getListingByToken查询 - 准备阶段");
        
        market.list(1, NFT_PRICE);
        marketAssembly.list(2, NFT_PRICE);
        
        console.log(unicode"测试getListingByToken查询 - 原版");
        uint256 gasBefore = gasleft();
        NFTMarket.Listing memory listing1 = market.getListingByToken(1);
        uint256 originalGas = gasBefore - gasleft();
        assertEq(listing1.tokenId, 1);
        
        console.log(unicode"测试getListingByToken查询 - 优化版");
        gasBefore = gasleft();
        NFTMarketAssembly.Listing memory listing2 = marketAssembly.getListingByToken(2);
        uint256 optimizedGas = gasBefore - gasleft();
        assertEq(listing2.tokenId, 2);
        
        _calculateGasReport("GetListingByToken", originalGas, optimizedGas);
    }

    // ============ 对比测试：错误情况 ============
    function test_RevertNotOwner() public {
        console.log(unicode"测试非所有者上架 - 原版");
        
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        market.list(1, NFT_PRICE);
        
        console.log(unicode"测试非所有者上架 - 优化版");
        
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        marketAssembly.list(1, NFT_PRICE);
    }

    function test_RevertInvalidPrice() public {
        console.log(unicode"测试无效价格 - 原版");
        
        vm.expectRevert(InvalidPrice.selector);
        market.list(1, 0);
        
        console.log(unicode"测试无效价格 - 优化版");
        
        vm.expectRevert(InvalidPrice.selector);
        marketAssembly.list(1, 0);
    }

    function test_RevertNFTNotListed() public {
        console.log(unicode"测试购买未上架NFT - 原版");
        
        vm.expectRevert(NFTNotListed.selector);
        market.buyNFT(999);
        
        console.log(unicode"测试购买未上架NFT - 优化版");
        
        vm.expectRevert(NFTNotListed.selector);
        marketAssembly.buyNFT(999);
    }

    // ============ 对比测试：事件测试 ============
    function test_ListEvent() public {
        console.log(unicode"测试上架事件 - 原版");
        
        uint256 expectedListId1 = market.nextListId() + 1;
        
        vm.expectEmit(true, true, false, true);
        emit Listed(expectedListId1, 1, NFT_PRICE, owner);
        market.list(1, NFT_PRICE);
        
        console.log(unicode"测试上架事件 - 优化版");
        
        uint256 expectedListId2 = marketAssembly.nextListId() + 1;
        
        vm.expectEmit(true, true, false, true);
        emit Listed(expectedListId2, 2, NFT_PRICE, owner);
        marketAssembly.list(2, NFT_PRICE);
    }

    function test_SoldEvent() public {
        console.log(unicode"测试售出事件 - 原版");
        
        market.list(1, NFT_PRICE);
        uint256 listId1 = market.tokenToListId(1);
        
        vm.startPrank(user1);
        token.approve(address(market), NFT_PRICE);
        vm.expectEmit(true, true, true, true);
        emit Sold(listId1, 1, user1, NFT_PRICE);
        market.buyNFT(listId1);
        vm.stopPrank();
        
        console.log(unicode"测试售出事件 - 优化版");
        
        marketAssembly.list(2, NFT_PRICE);
        uint256 listId2 = marketAssembly.tokenToListId(2);
        
        vm.startPrank(user2);
        token.approve(address(marketAssembly), NFT_PRICE);
        vm.expectEmit(true, true, true, true);
        emit Sold(listId2, 2, user2, NFT_PRICE);
        marketAssembly.buyNFT(listId2);
        vm.stopPrank();
    }

    function test_DelistEvent() public {
        console.log(unicode"测试下架事件 - 原版");
        
        market.list(1, NFT_PRICE);
        uint256 listId1 = market.tokenToListId(1);
        
        vm.expectEmit(true, true, false, false);
        emit Delisted(listId1, 1);
        market.delist(listId1);
        
        console.log(unicode"测试下架事件 - 优化版");
        
        marketAssembly.list(2, NFT_PRICE);
        uint256 listId2 = marketAssembly.tokenToListId(2);
        
        vm.expectEmit(true, true, false, false);
        emit Delisted(listId2, 2);
        marketAssembly.delist(listId2);
    }

    // ============ 对比测试：Fuzz测试 ============
    function test_FuzzRandomPriceListing(uint256 randomPrice) public {
        console.log(unicode"测试随机价格上架 - 对比版");
        
        uint256 price = (randomPrice % (20 ether)) + 0.01 ether;
        
        console.log(unicode"随机价格:", price);
        
        // 测试原版
        uint256 gasBefore = gasleft();
        market.list(1, price);
        uint256 originalGas = gasBefore - gasleft();
        
        NFTMarket.Listing memory listing1 = market.getListing(1);
        assertEq(listing1.tokenId, 1);
        assertEq(listing1.price, price);
        assertTrue(listing1.active);
        
        // 测试优化版
        gasBefore = gasleft();
        marketAssembly.list(2, price);
        uint256 optimizedGas = gasBefore - gasleft();
        
        NFTMarketAssembly.Listing memory listing2 = marketAssembly.getListing(1);
        assertEq(listing2.tokenId, 2);
        assertEq(listing2.price, price);
        assertTrue(listing2.active);
        
        _calculateGasReport("FuzzRandomPriceListing", originalGas, optimizedGas);
    }

    // ============ 最终Gas报告 ============
    function test_FinalGasReport() public {
        console.log("\n");
        console.log(unicode"==========================================");
        console.log(unicode"          最终Gas优化报告");
        console.log(unicode"==========================================");
        
        // 重新运行关键测试以获取准确数据
        _runComprehensiveGasTest();
        
        console.log(unicode"==========================================");
    }

    function _runComprehensiveGasTest() internal {
        // List测试
        uint256 gasBefore = gasleft();
        market.list(5, NFT_PRICE);
        uint256 originalListGas = gasBefore - gasleft();
        
        gasBefore = gasleft();
        marketAssembly.list(6, NFT_PRICE);
        uint256 optimizedListGas = gasBefore - gasleft();
        
        _calculateGasReport("Final_List", originalListGas, optimizedListGas);
        
        // Buy测试
        vm.startPrank(user1);
        token.approve(address(market), NFT_PRICE);
        gasBefore = gasleft();
        market.buyNFT(market.tokenToListId(5));
        uint256 originalBuyGas = gasBefore - gasleft();
        vm.stopPrank();
        
        vm.startPrank(user2);
        token.approve(address(marketAssembly), NFT_PRICE);
        gasBefore = gasleft();
        marketAssembly.buyNFT(marketAssembly.tokenToListId(6));
        uint256 optimizedBuyGas = gasBefore - gasleft();
        vm.stopPrank();
        
        _calculateGasReport("Final_Buy", originalBuyGas, optimizedBuyGas);
    }
}
