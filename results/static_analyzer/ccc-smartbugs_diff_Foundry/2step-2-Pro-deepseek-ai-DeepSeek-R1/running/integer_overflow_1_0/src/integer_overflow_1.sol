pragma solidity ^0.8.26;

contract Overflow {
    uint private sellerBalance = 0;
    uint public totalDeposits;
    mapping(address => uint) public userBalances;
    
    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);

    function add(uint value) public returns (bool) {
        unchecked {
            sellerBalance += value;
        }
        userBalances[msg.sender] += value;
        totalDeposits += value;
        emit Deposit(msg.sender, value);
        return true;
    }

    function withdraw(uint amount) public returns (bool) {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");
        unchecked {
            userBalances[msg.sender] -= amount;
            sellerBalance -= amount;
        }
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
        return true;
    }

    function getTotalBalance() public view returns (uint) {
        return sellerBalance;
    }
}