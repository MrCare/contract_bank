// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MyToken} from "src/token.sol";
import {TokenBankV2} from "src/tokenBankV2.sol";

contract TokenBankV2Test is Test {
    MyToken public token;
    TokenBankV2 public tokenBank;

    address public owner;
    address public user1;
    address public user2;
    address public user3;

    uint256 constant INITIAL_SUPPLY = 100 * 10 ** 18; // 100 CTK
    uint256 constant TEST_AMOUNT = 10 * 10 ** 18; // 10 CTK

    function setUp() public {
        // 设置测试地址
        owner = address(this);
        user1 = vm.addr(1);
        user2 = vm.addr(2);
        user3 = vm.addr(3);

        // 部署合约
        token = new MyToken();
        tokenBank = new TokenBankV2(token);

        // 给用户分发一些代币进行测试
        token.transfer(user1, 30 * 10 ** 18);
        token.transfer(user2, 20 * 10 ** 18);
        token.transfer(user3, 15 * 10 ** 18);
    }

    // ============ Token 基础功能测试 ============

    function test_tokenBasicInfo() public view {
        console.log(unicode"测试 Token 基础信息");
        assertEq(token.name(), "CarToken");
        assertEq(token.symbol(), "CTK");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_tokenBalances() public view {
        console.log(unicode"测试 Token 余额分配");
        assertEq(token.balanceOf(owner), 35 * 10 ** 18); // 100 - 30 - 20 - 15
        assertEq(token.balanceOf(user1), 30 * 10 ** 18);
        assertEq(token.balanceOf(user2), 20 * 10 ** 18);
        assertEq(token.balanceOf(user3), 15 * 10 ** 18);
    }

    // ============ TokenBank 基础功能测试 ============

    function test_tokenBankOwner() public view {
        console.log(unicode"测试 TokenBank 所有者");
        assertEq(tokenBank.owner(), owner);
        assertEq(address(tokenBank.tokenContract()), address(token));
    }

    function test_tokenBankDeposit() public {
        console.log(unicode"测试 TokenBank 存款功能(使用 transferWithCallback)");

        // user1 存款
        vm.prank(user1);
        token.transferWithCallback(address(tokenBank), TEST_AMOUNT);

        // 检查结果
        assertEq(tokenBank.getBalance(user1), TEST_AMOUNT);
        assertEq(token.balanceOf(user1), 20 * 10 ** 18); // 30 - 10
        assertEq(token.balanceOf(address(tokenBank)), TEST_AMOUNT);
    }

    function test_tokenBankWithdraw() public {
        console.log(unicode"测试 TokenBank 取款功能");

        // 先存款
        vm.prank(user1);
        token.approve(address(tokenBank), TEST_AMOUNT);
        vm.prank(user1);
        tokenBank.deposit(TEST_AMOUNT);

        // 再取款
        vm.prank(user1);
        tokenBank.withdraw(5 * 10 ** 18);

        // 检查结果
        assertEq(tokenBank.getBalance(user1), 5 * 10 ** 18);
        assertEq(token.balanceOf(user1), 25 * 10 ** 18); // 30 - 10 + 5
        assertEq(token.balanceOf(address(tokenBank)), 5 * 10 ** 18);
    }
}
