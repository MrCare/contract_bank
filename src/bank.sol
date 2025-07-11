// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IBank {
    function setAdmain(address addr) external;
    function total() external view returns (uint256);
    function deposit() external payable;
    function withdraw(uint x) external;
}

abstract contract Bank is IBank {
    mapping(address => uint) public balances;
    address[3] public topThree;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function total() external view returns (uint256) {
        return address(this).balance;
    }

    // 取款
    function withdraw(uint x) public isAdmin {
        require(x <= address(this).balance, "withdraw more than total balance");
        payable(msg.sender).transfer(x);
    }

    function _updateTopTree(address addr, uint amount) internal {
        uint i = 0;
        while (i < 3) {
            if (amount > balances[topThree[i]]) {
                address addrDropped = topThree[i];
                uint amountDropped = balances[topThree[i]];
                topThree[i] = addr;
                _updateTopTree(addrDropped, amountDropped);
                break;
            }
            i++;
        }
    }

    // 实现取款接口
    function _deposit() internal {
        balances[msg.sender] += msg.value; // 记录存款账户的存款总额
        _updateTopTree(msg.sender, balances[msg.sender]); // 更新前三个存款最多的人
    }

    // 存款
    function deposit() external payable virtual {
        _deposit();
    }

    modifier isAdmin() {
        require(msg.sender == admin, "you are not admin!");
        _;
    }

    receive() external payable {
        this.deposit();
    }
}

contract Bigbank is Bank {
    modifier enoughAmount(){
        require(msg.value > 0.001 ether, 'amount must > 0.001 eth!');
        _;
    }
    
    function setAdmain(address addr) external isAdmin {
        admin = addr;
    }

    function deposit() public payable override enoughAmount {
        _deposit();
    }
}