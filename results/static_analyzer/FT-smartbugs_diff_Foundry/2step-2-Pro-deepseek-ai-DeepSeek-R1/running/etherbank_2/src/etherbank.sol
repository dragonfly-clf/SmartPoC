pragma solidity ^0.8.26;

contract EtherBank {
    mapping (address => uint) userBalances;
    address public owner;
    uint public totalDeposits;
    uint public totalWithdrawals;
    
    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);
    event InterestPaid(address indexed user, uint amount);

    constructor() {
        owner = msg.sender;
    }

    function getBalance(address user) public view returns(uint) {  
        return userBalances[user];
    }

    function addToBalance() public payable {  
        userBalances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawBalance() public {  
        uint amountToWithdraw = userBalances[msg.sender];
        // <yes> <report> REENTRANCY
        (bool success, ) = msg.sender.call{value: amountToWithdraw}("");
        if (!success) { revert(); }
        userBalances[msg.sender] = 0;
        totalWithdrawals += amountToWithdraw;
        emit Withdrawal(msg.sender, amountToWithdraw);
    }

    function payInterest(address user) public {
        require(msg.sender == owner, "Only owner can pay interest");
        uint interest = userBalances[user] / 100; // 1% interest
        userBalances[user] += interest;
        emit InterestPaid(user, interest);
    }

    function getTotalBankBalance() public view returns(uint) {
        return address(this).balance;
    }
}