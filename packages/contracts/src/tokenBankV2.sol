// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MyToken} from "./token.sol";
import {TokenBank} from "./tokenBank.sol";
import {ITokenBankV2} from "./token.sol";

contract TokenBankV2 is TokenBank, ITokenBankV2 {
    // 定义收到转账的事件
    event TokensReceived(address indexed from, uint256 amount);
    event DataReceived(address indexed from, uint256 amount, bytes data);

    // 重新声明为 MyToken 类型
    MyToken public myTokenContract;

    constructor(MyToken _tokenContract) TokenBank(_tokenContract) {
        myTokenContract = _tokenContract; // 需要在构造函数中重新申明才行
    }

    function tokensReceived(address from, uint256 amount, bytes calldata _data) external returns (bool) {
        require(msg.sender == address(myTokenContract), "Only token contract can call this function");
        if (_data.length > 0) {
            emit DataReceived(from, amount, _data);
        }

        // 增加用户在 TokenBank 中的余额
        balances[from] += amount;

        // 触发事件
        emit TokensReceived(from, amount);

        return true;
    }
}
