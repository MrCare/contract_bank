// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Admin} from "src/admin.sol";
import {Bigbank} from "src/bank.sol";

contract AdminTest is Test {
    Admin public admin;
    Bigbank public bank;
    address deployerAdminAddress;
    address deployerBankAddress;
    address customer;

    function setUp() public {
        bank = new Bigbank();
        deployerBankAddress = address(this);

        deployerAdminAddress = vm.addr(1);
        vm.prank(deployerAdminAddress);
        admin = new Admin();
        customer = vm.addr(2);
        // vm.deal(deployerAdminAddress, 1 ether);
        vm.deal(customer, 11 ether);
    }

    function test_transferAdmin() public {
        console.log(unicode"将 bank 合约管理员转移给 admin 合约");
        bank.setAdmain(address(admin));
        assertEq(bank.admin(), address(admin));
    }

    function test_withdraw() public {
        console.log(unicode"将 bank 合约的钱转移至 admin 中，并由owner 从admin合约中取出");
        vm.prank(customer);
        bank.deposit{value: 10 ether}();
        bank.setAdmain(address(admin));
        admin.adminWithdraw(bank); // 从 bank 提取资金到 admin
        assertEq(address(admin).balance, 10 ether);

        uint256 initialBalance = deployerAdminAddress.balance;
        vm.prank(deployerAdminAddress);
        admin.withdraw(); // 从admin提取到owner
        assertEq(deployerAdminAddress.balance, initialBalance + 10 ether);
    }
}
