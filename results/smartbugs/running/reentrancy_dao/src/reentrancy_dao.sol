pragma solidity ^0.8.26;

contract ReentrancyDAO {
    mapping (address => uint) credit;
    uint balance;
    uint public totalDeposits;
    uint public totalWithdrawals;
    mapping(address => uint) public depositCount;
    
    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);

    function withdrawAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            unchecked {
                balance -= oCredit;
            }
            totalWithdrawals += oCredit;
            // <yes> <report> REENTRANCY
            (bool callResult, ) = payable(msg.sender).call{value: oCredit}("");
            require(callResult);
            credit[msg.sender] = 0;
            emit Withdrawal(msg.sender, oCredit);
        }
    }

    function deposit() public payable {
        unchecked {
            credit[msg.sender] += msg.value;
            balance += msg.value;
        }
        totalDeposits += msg.value;
        depositCount[msg.sender]++;
        emit Deposit(msg.sender, msg.value);
    }

    function getUserCredit(address user) public view returns (uint) {
        return credit[user];
    }

    function getContractBalance() public view returns (uint) {
        return balance;
    }
}