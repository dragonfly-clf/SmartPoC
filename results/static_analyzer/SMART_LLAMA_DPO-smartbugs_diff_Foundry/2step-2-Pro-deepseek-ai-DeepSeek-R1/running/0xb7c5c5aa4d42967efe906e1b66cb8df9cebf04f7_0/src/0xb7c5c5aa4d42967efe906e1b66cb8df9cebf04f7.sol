pragma solidity ^0.8.26;

contract keepMyEther {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    mapping(address => uint256) public depositCount;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    
    receive() external payable {
        unchecked {
            balances[msg.sender] += msg.value;
        }
        totalDeposits += msg.value;
        depositCount[msg.sender]++;
        emit Deposit(msg.sender, msg.value);
    }
    
    function withdraw() public {
        uint256 amount = balances[msg.sender];
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success);
        balances[msg.sender] = 0;
        totalWithdrawals += amount;
        emit Withdrawal(msg.sender, amount);
    }
    
    function getUserStats(address user) public view returns (uint256 balance, uint256 deposits) {
        return (balances[user], depositCount[user]);
    }
}