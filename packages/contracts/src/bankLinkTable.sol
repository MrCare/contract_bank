// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BankLinkTable {
    struct Node {
        address user;
        uint256 amount;
        address next;
    }
    
    mapping(address => uint256) public balances;
    mapping(address => Node) public nodes;
    address public head;
    address public admin;
    uint256 public topCount;
    
    constructor() {
        admin = msg.sender;
    }
    
    modifier isAdmin() {
        require(msg.sender == admin, "you are not admin!");
        _;
    }
    
    modifier enoughAmount() {
        require(msg.value > 0.001 ether, "amount must > 0.001 eth!");
        _;
    }
    
    function setAdmain(address addr) external isAdmin {
        admin = addr;
    }
    
    function withdraw(uint256 x) external isAdmin {
        require(x <= address(this).balance, "withdraw more than total balance");
        payable(msg.sender).transfer(x);
    }
    
    // 离线计算存款
    function deposit(address insertAfter) external payable enoughAmount {
        balances[msg.sender] += msg.value;
        uint256 newAmount = balances[msg.sender];
        
        require(_validPosition(newAmount, insertAfter), "Invalid position");
        
        _remove(msg.sender);
        
        address next = (insertAfter == address(0)) ? head : nodes[insertAfter].next;
        nodes[msg.sender] = Node(msg.sender, newAmount, next);
        
        if (insertAfter == address(0)) {
            head = msg.sender;
        } else {
            nodes[insertAfter].next = msg.sender;
        }
        
        topCount++;
        _maintainTop10();
    }
    
    function _validPosition(uint256 amount, address insertAfter) internal view returns (bool) {
        if (insertAfter == address(0)) {
            return head == address(0) || amount >= nodes[head].amount;
        }
        
        if (nodes[insertAfter].user == address(0)) return false;
        if (amount > nodes[insertAfter].amount) return false;
        
        address next = nodes[insertAfter].next;
        return next == address(0) || amount >= nodes[next].amount;
    }
    
    function _remove(address user) internal {
        if (nodes[user].user == address(0)) return;
        
        if (head == user) {
            head = nodes[user].next;
        } else {
            address prev = head;
            while (nodes[prev].next != user) {
                prev = nodes[prev].next;
            }
            nodes[prev].next = nodes[user].next;
        }
        
        delete nodes[user];
        topCount--;
    }
    
    function _maintainTop10() internal {
        if (topCount > 10) {
            address curr = head;
            for (uint256 i = 0; i < 9; i++) {
                curr = nodes[curr].next;
            }
            
            address toRemove = nodes[curr].next;
            nodes[curr].next = address(0);
            
            while (toRemove != address(0)) {
                address next = nodes[toRemove].next;
                delete nodes[toRemove];
                topCount--;
                toRemove = next;
            }
        }
    }
    
    function getTop10() external view returns (address[] memory, uint256[] memory) {
        address[] memory users = new address[](topCount);
        uint256[] memory amounts = new uint256[](topCount);
        
        address curr = head;
        for (uint256 i = 0; i < topCount; i++) {
            users[i] = curr;
            amounts[i] = nodes[curr].amount;
            curr = nodes[curr].next;
        }
        
        return (users, amounts);
    }
    
    fallback() external payable {
        require(msg.value > 0.001 ether, "amount must > 0.001 eth!");
        require(msg.data.length >= 20, "Missing insertAfter address");
        
        // 使用abi.decode解析insertAfter地址
        address insertAfter = abi.decode(msg.data, (address));
        
        balances[msg.sender] += msg.value;
        uint256 newAmount = balances[msg.sender];
        
        require(_validPosition(newAmount, insertAfter), "Invalid position");
        
        _remove(msg.sender);
        
        address next = (insertAfter == address(0)) ? head : nodes[insertAfter].next;
        nodes[msg.sender] = Node(msg.sender, newAmount, next);
        
        if (insertAfter == address(0)) {
            head = msg.sender;
        } else {
            nodes[insertAfter].next = msg.sender;
        }
        
        topCount++;
        _maintainTop10();
    }
    
    receive() external payable {
        revert("Use deposit(insertAfter) or send with data");
    }
}