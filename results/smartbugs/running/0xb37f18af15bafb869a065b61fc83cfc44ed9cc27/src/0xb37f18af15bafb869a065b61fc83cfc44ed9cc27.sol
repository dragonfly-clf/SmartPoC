pragma solidity ^0.8.26;

contract SimpleWallet {
    address public owner = msg.sender;
    uint public depositsCount;
    uint public totalDeposited;
    uint public totalWithdrawn;
    mapping(address => uint) public userDeposits;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    receive() external payable {
        depositsCount++;
        totalDeposited += msg.value;
        userDeposits[msg.sender] += msg.value;
    }
    
    function withdrawAll() public onlyOwner {
        withdraw(address(this).balance);
    }
    
    function withdraw(uint _value) public onlyOwner {
        payable(msg.sender).transfer(_value);
        totalWithdrawn += _value;
    }
    
    function sendMoney(address _target, uint _value) public onlyOwner {
        (bool success, ) = _target.call{value: _value}("");
    }
    
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function getUserDeposit(address _user) public view returns (uint) {
        return userDeposits[_user];
    }
}