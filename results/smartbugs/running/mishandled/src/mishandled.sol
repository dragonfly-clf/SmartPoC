pragma solidity ^0.8.26;

contract SendBack {
    mapping(address => uint256) public userBalances;
    address public owner;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    
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
    
    function withdrawBalance() public {
        uint256 amountToWithdraw = userBalances[msg.sender];
        userBalances[msg.sender] = 0;
        totalWithdrawals += amountToWithdraw;
        payable(msg.sender).send(amountToWithdraw);
        emit Withdrawal(msg.sender, amountToWithdraw);
    }
    
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}