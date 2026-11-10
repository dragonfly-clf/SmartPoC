pragma solidity ^0.8.26;

contract Caller {
    address public owner;
    uint public totalCalls;
    mapping(address => uint) public callCounts;
    
    event CallMade(address indexed target, address indexed caller, uint timestamp);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        owner = msg.sender;
    }
    
    function callAddress(address a) public {
        payable(a).call("");
        totalCalls++;
        callCounts[msg.sender]++;
        emit CallMade(a, msg.sender, block.timestamp);
    }
    
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only owner can transfer ownership");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    function withdrawFees() public {
        require(msg.sender == owner, "Only owner can withdraw fees");
        payable(owner).transfer(address(this).balance);
    }
}