pragma solidity ^0.8.26;

contract SimpleWallet {
    address public owner = msg.sender;
    uint public depositsCount;
    uint public totalWithdrawn;
    uint public maxWithdrawal = 5 ether;
    mapping(address => uint) public userDeposits;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    event Deposit(address indexed depositor, uint amount);
    event Withdrawal(address indexed owner, uint amount);
    event MoneySent(address indexed target, uint amount);
    
    receive() external payable {
        depositsCount++;
        userDeposits[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    function withdrawAll() public onlyOwner {
        withdraw(address(this).balance);
    }
    
    function withdraw(uint _value) public onlyOwner {
        require(_value <= maxWithdrawal, "Exceeds maximum withdrawal limit");
        payable(msg.sender).transfer(_value);
        totalWithdrawn += _value;
        emit Withdrawal(msg.sender, _value);
    }
    
    function sendMoney(address _target, uint _value, bytes memory _data) public onlyOwner {
        (bool success, ) = _target.call{value: _value}(_data);
        emit MoneySent(_target, _value);
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}