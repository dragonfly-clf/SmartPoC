pragma solidity ^0.8.26;

contract Reentrancy_insecure {
    mapping(address => uint256) private userBalances;
    uint256 public totalDeposits;
    mapping(address => uint256) public depositCount;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        userBalances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        depositCount[msg.sender]++;
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawBalance() public {
        uint256 amountToWithdraw = userBalances[msg.sender];
        require(amountToWithdraw > 0, "No balance to withdraw");
        
        (bool success, ) = payable(msg.sender).call{value: amountToWithdraw}("");
        require(success);
        userBalances[msg.sender] = 0;
        
        emit Withdrawal(msg.sender, amountToWithdraw);
    }

    function getBalance(address user) public view returns (uint256) {
        return userBalances[user];
    }
}