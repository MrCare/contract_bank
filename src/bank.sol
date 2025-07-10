// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Bank {
    mapping (address => uint) public balances;
    address[3] public topThree; 
    address public admin;
    uint256 public total;
    
    constructor(){
        admin = msg.sender;
    }
    function setAdmain(address addr) public isAdmin{
        admin = addr;
    }
    
    // 取款
    function withdraw(uint x) public isAdmin{
        require(x < total, "withdraw more than total");
        total -= x;
        payable(msg.sender).transfer(x);
    }

    function _updateTopTree(address addr, uint amount) internal {
        uint i = 0;
        while (i < 3){
            if (amount > balances[topThree[i]]){
                address addrDropped = topThree[i];
                uint amountDropped = balances[topThree[i]];
                topThree[i] = addr;
                _updateTopTree(addrDropped,amountDropped);
                break;
            }
            i++;
        }
    }

    // 存款
    function deposit() public payable{
        balances[msg.sender] += msg.value; // 记录存款账户的存款总额
        total += msg.value; // 可以删除只用合约余额 记录bank中存款总额
        _updateTopTree(msg.sender, msg.value); // 更新前三个存款最多的人

    }
    modifier isAdmin {
        require(msg.sender == admin, "you are not admin!");
        _;
    }
}
