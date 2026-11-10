pragma solidity ^0.8.26;

contract EtherStore {
    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;
    address public owner;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function depositFunds() public payable {
        unchecked {
            balances[msg.sender] += msg.value;
        }
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawFunds (uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);
        require(_weiToWithdraw <= withdrawalLimit);
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 weeks);
        // <yes> <report> REENTRANCY
        (bool success, ) = msg.sender.call{value: _weiToWithdraw}("");
        require(success);
        unchecked {
            balances[msg.sender] -= _weiToWithdraw;
        }
        lastWithdrawTime[msg.sender] = block.timestamp;
        totalWithdrawals += _weiToWithdraw;
        emit Withdrawal(msg.sender, _weiToWithdraw);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address user) public view returns (uint256) {
        return balances[user];
    }
}