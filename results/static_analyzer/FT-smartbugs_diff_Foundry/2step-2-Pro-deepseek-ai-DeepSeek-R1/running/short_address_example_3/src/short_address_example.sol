pragma solidity ^0.8.26;

contract MyToken {
    mapping(address => uint256) balances;
    address public owner;
    uint256 public totalSupply;
    uint256 public transactionFee = 10; // 1% fee

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event FeeCollected(address indexed from, uint256 amount);

    constructor() {
        unchecked {
            balances[tx.origin] = 10000;
            totalSupply = 10000;
            owner = tx.origin;
        }
    }

    function sendCoin(address to, uint256 amount) public returns (bool sufficient) {
        unchecked {
            if (balances[msg.sender] < amount) return false;
            
            // Apply transaction fee
            uint256 fee = amount * transactionFee / 1000;
            uint256 transferAmount = amount - fee;
            
            balances[msg.sender] -= amount;
            balances[to] += transferAmount;
            balances[owner] += fee;
            
            emit FeeCollected(msg.sender, fee);
            emit Transfer(msg.sender, to, transferAmount);
        }
        return true;
    }

    function getBalance(address addr) public view returns (uint256) {
        return balances[addr];
    }

    function setTransactionFee(uint256 newFee) public {
        require(msg.sender == owner, "Only owner can set fee");
        transactionFee = newFee;
    }
}