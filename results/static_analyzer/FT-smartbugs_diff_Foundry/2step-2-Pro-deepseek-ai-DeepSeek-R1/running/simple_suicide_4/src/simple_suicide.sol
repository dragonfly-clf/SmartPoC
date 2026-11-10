pragma solidity ^0.8.26;

contract SimpleSuicide {
    address public owner;
    uint256 public totalDeposits;
    mapping(address => uint256) public userBalances;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    
    constructor() {
        owner = msg.sender;
    }
    
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        userBalances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    function withdraw(uint256 amount) external {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");
        userBalances[msg.sender] -= amount;
        totalDeposits -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
    
    function sudicideAnyone() public {
        selfdestruct(payable(msg.sender));
    }
    
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}