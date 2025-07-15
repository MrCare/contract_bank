// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenBank {
    address public owner;
    ERC20 public tokenContract;
    mapping(address => uint256) public balances;

    constructor(ERC20 _tokenContract) {
        owner = msg.sender;
        tokenContract = _tokenContract;
    }

    function setTokenContract(ERC20 _tokenContract) public {
        require(msg.sender == owner, "Only owner can set token contract");
        tokenContract = _tokenContract;
    }

    function deposit(uint256 amount) public virtual{
        require(amount > 0, "Amount must be greater than 0");
        require(tokenContract.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");

        balances[msg.sender] += amount;
        tokenContract.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        tokenContract.transfer(msg.sender, amount);
    }

    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }
}
