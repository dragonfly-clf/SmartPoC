pragma solidity ^0.8.26;

contract Proxy {
    address owner;
    uint public totalTransactions;
    mapping(address => uint) public userTransactionCount;
    
    event TransactionForwarded(address indexed user, address indexed callee, uint timestamp);

    constructor() {
        owner = msg.sender;
    }

    function forward(address callee, bytes memory _data) public {
        (bool success, ) = callee.delegatecall(_data);
        require(success);
        
        totalTransactions++;
        userTransactionCount[msg.sender]++;
        emit TransactionForwarded(msg.sender, callee, block.timestamp);
    }

    function getUserStats(address user) public view returns (uint) {
        return userTransactionCount[user];
    }
}