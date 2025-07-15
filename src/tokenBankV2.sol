// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MyToken} from "./token.sol";
import {TokenBank} from "./tokenBank.sol";
import {ITokenBankV2} from "./token.sol";

contract TokenBankV2 is TokenBank, ITokenBankV2 {
    // 定义收到转账的事件
    event TokensReceived(address indexed from, uint256 amount);

    // 重新声明为 MyToken 类型
    MyToken public myTokenContract;

    constructor(MyToken _tokenContract) TokenBank(_tokenContract) {
        myTokenContract = _tokenContract; // 需要在构造函数中重新申明才行
    }

    function tokensReceived(address from, uint256 amount) external returns (bool) {
        require(msg.sender == address(myTokenContract), "Only token contract can call this function");
        require(amount <= myTokenContract.balanceOf(from), "Insufficient balance");
        balances[from] += amount;

        // 触发事件
        emit TokensReceived(from, amount);

        return true;
    }
}
