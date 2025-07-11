// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { Bigbank } from "../src/bank.sol";

contract BankTest is Test {
    Bigbank public bank;
    address deployerAddress;
    address addrA;
    address addrB;
    address addrC;

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
        console.log(
            unicode"setAdmin() -> 检查是否能够重新设置管理员账户为addrA"
        );
        // 切换到不同地址执行操作
        vm.prank(deployerAddress);
        bank.setAdmain(addrA);
        assertEq(bank.admin(), addrA);
    }

    function test_deposit() public {
        console.log(unicode"deposit() -> 检查是否能够正常存款，查看余额");
        vm.expectRevert(bytes('amount must > 0.001 eth!')); // expectRevert 要放在前面做；
        vm.prank(addrA);
        bank.deposit{value: 100 wei}();
        
        vm.prank(addrA);
        bank.deposit{value: 0.01 ether}();
        assertEq(bank.balances(addrA), 0.01 ether);
    }

    function test_topThree() public {
        console.log(unicode"topThree() -> 检查是否能够正常记录top3");
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
}
