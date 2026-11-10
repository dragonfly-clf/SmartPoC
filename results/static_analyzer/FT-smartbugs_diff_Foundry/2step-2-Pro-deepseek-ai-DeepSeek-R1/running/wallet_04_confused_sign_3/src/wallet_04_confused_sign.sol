pragma solidity ^0.8.26;

contract Wallet {
    address creator;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    mapping(address => uint256) balances;
    mapping(address => uint256) public depositCount;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event Migration(address indexed to, uint256 amount);

    constructor() {
        creator = msg.sender;
    }

    function deposit() public payable {
        assert(balances[msg.sender] + msg.value > balances[msg.sender]);
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        depositCount[msg.sender]++;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        require(amount >= balances[msg.sender]);
        payable(msg.sender).transfer(amount);
        balances[msg.sender] -= amount;
        totalWithdrawals += amount;
        emit Withdrawal(msg.sender, amount);
    }

    function migrateTo(address to) public {
        require(creator == msg.sender);
        payable(to).transfer(address(this).balance);
        emit Migration(to, address(this).balance);
    }

    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }
}