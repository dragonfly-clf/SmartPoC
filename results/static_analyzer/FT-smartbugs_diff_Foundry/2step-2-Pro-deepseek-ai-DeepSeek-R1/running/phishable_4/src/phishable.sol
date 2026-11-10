pragma solidity ^0.8.26;

contract Phishable {
    address public owner;
    uint public totalDeposits;
    uint public totalWithdrawals;
    mapping(address => uint) public userBalances;

    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed recipient, uint amount);

    constructor(address _owner) {
        owner = _owner;
    }

    receive() external payable {
        totalDeposits += msg.value;
        userBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawAll(address _recipient) public {
        require(tx.origin == owner);
        uint balance = address(this).balance;
        payable(_recipient).transfer(balance);
        totalWithdrawals += balance;
        emit Withdrawal(_recipient, balance);
    }

    function getUserBalance(address user) public view returns (uint) {
        return userBalances[user];
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}