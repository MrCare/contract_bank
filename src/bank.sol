// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Bank {
    mapping(address => uint256) public balances;
    address[3] public topThree;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function setAdmain(address addr) public isAdmin {
        admin = addr;
    }

    function total() public view returns (uint256) {
        return address(this).balance;
    }

    // 取款
    function withdraw(uint256 x) public isAdmin {
        require(x <= address(this).balance, "withdraw more than total balance");
        payable(msg.sender).transfer(x);
    }

    function _updateTopTree(address addr, uint256 amount) internal {
        uint256 i = 0;
        while (i < 3) {
            if (amount > balances[topThree[i]]) {
                address addrDropped = topThree[i];
                uint256 amountDropped = balances[topThree[i]];
                topThree[i] = addr;
                _updateTopTree(addrDropped, amountDropped);
                break;
            }
            i++;
        }
    }

    // 存款
    function deposit() public payable {
        balances[msg.sender] += msg.value; // 记录存款账户的存款总额
        _updateTopTree(msg.sender, balances[msg.sender]); // 更新前三个存款最多的人
    }

    modifier isAdmin() {
        require(msg.sender == admin, "you are not admin!");
        _;
    }

    receive() external payable {
        deposit();
    }
}
