pragma solidity ^0.8.26;

contract SimpleDAO {
    mapping (address => uint) public credit;
    uint public totalDonations;
    uint public totalWithdrawals;
    address public owner;
    
    event DonationReceived(address indexed donor, address indexed recipient, uint amount);
    event WithdrawalProcessed(address indexed recipient, uint amount);

    constructor() {
        owner = msg.sender;
    }

    function donate(address to) public payable {
        unchecked {
            credit[to] += msg.value;
        }
        totalDonations += msg.value;
        emit DonationReceived(msg.sender, to, msg.value);
    }

    function withdraw(uint amount) public {
        if (credit[msg.sender] >= amount) {
            // <yes> <report> REENTRANCY
            (bool res, ) = payable(msg.sender).call{value: amount}("");
            unchecked {
                credit[msg.sender] -= amount;
            }
            totalWithdrawals += amount;
            emit WithdrawalProcessed(msg.sender, amount);
        }
    }

    function queryCredit(address to) public view returns (uint) {
        return credit[to];
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}