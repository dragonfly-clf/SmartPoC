pragma solidity ^0.8.26;

contract Reentrancy_cross_function {

    // INSECURE
    mapping (address => uint) private userBalances;
    mapping (address => uint) public lastWithdrawTime;
    uint public totalDeposits;
    uint public totalWithdrawals;

    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);

    function deposit() public payable {
        userBalances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function transfer(address to, uint amount) public {
        if (userBalances[msg.sender] >= amount) {
            unchecked {
                userBalances[to] += amount;
                userBalances[msg.sender] -= amount;
            }
        }
    }

    function withdrawBalance() public {
        uint amountToWithdraw = userBalances[msg.sender];
        require(amountToWithdraw > 0, "No balance to withdraw");
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 days, "Can only withdraw once per day");
        
        lastWithdrawTime[msg.sender] = block.timestamp;
        totalWithdrawals += amountToWithdraw;
        
        // <yes> <report> REENTRANCY
        (bool success, ) = payable(msg.sender).call{value: amountToWithdraw}("");
        require(success);
        userBalances[msg.sender] = 0;
        
        emit Withdrawal(msg.sender, amountToWithdraw);
    }

    function getBalance(address user) public view returns (uint) {
        return userBalances[user];
    }
}