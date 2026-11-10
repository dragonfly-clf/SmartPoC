pragma solidity ^0.8.26;

contract MyContract {
    address owner;
    uint public totalTransfers;
    mapping(address => uint) public recipientBalances;
    
    event TransferSent(address indexed from, address indexed to, uint amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == owner);
        payable(receiver).transfer(amount);
        totalTransfers++;
        recipientBalances[receiver] += amount;
        emit TransferSent(msg.sender, receiver, amount);
    }

    function transferOwnership(address newOwner) public {
        require(tx.origin == owner);
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}