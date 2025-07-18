// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Bigbank} from "../src/bank.sol";

contract BankTest is Test {
    Bigbank public bank;
    address deployerAddress;
    address addrA;
    address addrB;
    address addrC;

    // 添加 receive 函数以接收 ETH
    receive() external payable {}

    function setUp() public {
        bank = new Bigbank();
        deployerAddress = address(this);
        addrA = vm.addr(1);
        addrB = vm.addr(2);
        addrC = vm.addr(3);
        vm.deal(addrA, 10 ether);
        vm.deal(addrB, 10 ether);
        vm.deal(addrC, 10 ether);
    }

    function test_admin() public view {
        console.log(unicode"admin() -> 检查合约管理员地址是否为部署合约的地址");
        assertEq(bank.admin(), deployerAddress);
    }

    function test_cantSetAdmin() public {
        console.log(unicode"setAdmin() -> 检查非管理员是否能够调用setAdmin()");
        // 切换到不同地址执行操作
        vm.expectRevert(bytes("you are not admin!"));
        vm.prank(addrA);
        bank.setAdmain(addrA);
    }

    function test_setAdmin() public {
        console.log(unicode"setAdmin() -> 检查是否能够重新设置管理员账户为addrA");
        // 切换到不同地址执行操作
        vm.prank(deployerAddress);
        bank.setAdmain(addrA);
        assertEq(bank.admin(), addrA);
    }

    function test_deposit() public {
        console.log(unicode"deposit() -> 1. 断言检查存款前后用户在 Bank 合约中的存款额更新是否正确");
        vm.expectRevert(bytes("amount must > 0.001 eth!")); // expectRevert 要放在前面做；
        vm.prank(addrA);
        bank.deposit{value: 100 wei}();

        vm.prank(addrA);
        bank.deposit{value: 0.01 ether}();
        assertEq(bank.balances(addrA), 0.01 ether);
    }

    function test_topThree() public {
        console.log(unicode"topThree() -> 2. 检查存款金额的前 3 名用户是否正确，分别检查有1个、2个、3个、4 个用户， 以及同一个用户多次存款的情况");
        vm.prank(deployerAddress);
        bank.deposit{value: 0.01 ether}();
        assertEq(bank.topThree(0), deployerAddress);

        vm.prank(addrA);
        bank.deposit{value: 0.02 ether}();
        assertEq(bank.balances(addrA), 0.02 ether); // 此时已经没有之前的 100 wei 了
        assertEq(bank.topThree(0), addrA);
        assertEq(bank.topThree(1), deployerAddress);

        vm.prank(addrB);
        bank.deposit{value: 0.2 ether}();
        assertEq(bank.topThree(0), addrB);
        assertEq(bank.topThree(1), addrA);
        assertEq(bank.topThree(2), deployerAddress);

        vm.prank(addrC);
        bank.deposit{value: 2 ether}();
        assertEq(bank.topThree(0), addrC);
        assertEq(bank.topThree(1), addrB);
        assertEq(bank.topThree(2), addrA);
    }

    function test_withdraw() public {
        console.log(unicode"withdraw() -> 3. 检查只有管理员能够取钱，非管理员无法取钱");

        // 先让合约有一些余额 - 用户存款
        vm.prank(addrA);
        bank.deposit{value: 1 ether}();

        vm.prank(addrB);
        bank.deposit{value: 2 ether}();

        // 验证合约余额
        uint256 contractBalance = address(bank).balance;
        assertEq(contractBalance, 3 ether);
        console.log(unicode"合约总余额:", contractBalance);

        // 1. 测试非管理员无法取钱
        console.log(unicode"测试非管理员 addrA 无法取钱");
        vm.expectRevert(bytes("you are not admin!"));
        vm.prank(addrA);
        bank.withdraw(0.5 ether);

        // 2. 测试另一个非管理员无法取钱
        console.log(unicode"测试非管理员 addrB 无法取钱");
        vm.expectRevert(bytes("you are not admin!"));
        vm.prank(addrB);
        bank.withdraw(1 ether);

        // 3. 测试管理员可以取钱
        console.log(unicode"测试管理员可以取钱");
        uint256 adminBalanceBefore = deployerAddress.balance;
        uint256 withdrawAmount = 1.5 ether;

        // 管理员取钱
        vm.prank(deployerAddress);
        bank.withdraw(withdrawAmount);

        // 验证取钱后的余额变化
        uint256 adminBalanceAfter = deployerAddress.balance;
        uint256 contractBalanceAfter = address(bank).balance;

        assertEq(adminBalanceAfter, adminBalanceBefore + withdrawAmount);
        assertEq(contractBalanceAfter, contractBalance - withdrawAmount);

        console.log(unicode"管理员取钱前余额:", adminBalanceBefore);
        console.log(unicode"管理员取钱后余额:", adminBalanceAfter);
        console.log(unicode"合约取钱后余额:", contractBalanceAfter);

        // 4. 测试取款金额超过合约余额的情况
        console.log(unicode"测试取款金额超过合约余额");
        vm.expectRevert(bytes("withdraw more than total balance"));
        vm.prank(deployerAddress);
        bank.withdraw(10 ether); // 超过合约余额

        // 5. 测试管理员可以取出所有余额
        console.log(unicode"测试管理员可以取出所有余额");
        uint256 remainingBalance = address(bank).balance;
        vm.prank(deployerAddress);
        bank.withdraw(remainingBalance);

        // 验证合约余额为0
        assertEq(address(bank).balance, 0);
        console.log(unicode"取出所有余额后合约余额:", address(bank).balance);
    }
}
