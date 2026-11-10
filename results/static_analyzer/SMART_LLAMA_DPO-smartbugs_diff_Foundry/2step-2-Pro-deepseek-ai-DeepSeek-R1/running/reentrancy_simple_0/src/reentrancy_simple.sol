pragma solidity ^0.8.26;

contract Reentrance {
    mapping (address => uint) public userBalance;
    address public owner;
    uint public totalDeposits;
    uint public totalWithdrawals;
    
    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);

    constructor() {
        owner = msg.sender;
    }

    function getBalance(address u) public view returns(uint){
        return userBalance[u];
    }

    function addToBalance() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        unchecked {
            userBalance[msg.sender] += msg.value;
        }
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawBalance() public {
        require(userBalance[msg.sender] > 0, "No balance to withdraw");
        uint amount = userBalance[msg.sender];
        
        // send userBalance[msg.sender] ethers to msg.sender
        // if mgs.sender is a contract, it will call its fallback function
        // <yes> <report> REENTRANCY
        (bool success, ) = msg.sender.call{value: amount}("");
        if(!success){
            revert();
        }
        
        userBalance[msg.sender] = 0;
        totalWithdrawals += amount;
        emit Withdrawal(msg.sender, amount);
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}