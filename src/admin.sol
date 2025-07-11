// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { IBank } from "./bank.sol";


contract Admin {
    address public owner;
    constructor(){
        owner = msg.sender;
    }
    // 全部取出到本合约中
    function adminWithdraw(IBank bank) public{
        bank.withdraw(address(bank).balance);
    }
    // 全部由owner取出
    function withdraw() public{
        require(msg.sender == owner, "not admin!");
        (bool success, ) = payable(msg.sender).call{value:address(this).balance}("");
        require(success, "Transfer failed!");
    }
    receive() external payable {}
}