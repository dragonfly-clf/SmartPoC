pragma solidity ^0.8.26;

contract TimeLock {
    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;
    address public owner;
    uint public totalDeposits;
    uint public totalWithdrawals;
    
    event Deposit(address indexed user, uint amount, uint lockUntil);
    event Withdrawal(address indexed user, uint amount);
    event LockTimeIncreased(address indexed user, uint newLockTime);

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        unchecked {
            balances[msg.sender] += msg.value;
        }
        lockTime[msg.sender] = block.timestamp + 1 weeks;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value, lockTime[msg.sender]);
    }

    function increaseLockTime(uint _secondsToIncrease) public {
        unchecked {
            lockTime[msg.sender] += _secondsToIncrease;
        }
        emit LockTimeIncreased(msg.sender, lockTime[msg.sender]);
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "No balance to withdraw");
        require(block.timestamp > lockTime[msg.sender], "Funds are still locked");
        uint transferValue = balances[msg.sender];
        balances[msg.sender] = 0;
        totalWithdrawals += transferValue;
        payable(msg.sender).transfer(transferValue);
        emit Withdrawal(msg.sender, transferValue);
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}