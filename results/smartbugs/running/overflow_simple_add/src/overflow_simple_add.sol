pragma solidity ^0.8.26;

contract Overflow_Add {
    uint public balance = 1;
    mapping(address => uint) public deposits;
    uint public totalDeposits;
    address public owner;

    event DepositMade(address indexed depositor, uint amount);
    event BalanceUpdated(uint newBalance);

    constructor() {
        owner = msg.sender;
    }

    function add(uint256 deposit) public {
        deposits[msg.sender] += deposit;
        totalDeposits += deposit;
        
        unchecked {
            balance += deposit;
        }
        
        emit DepositMade(msg.sender, deposit);
        emit BalanceUpdated(balance);
    }

    function getMyDeposit() public view returns (uint) {
        return deposits[msg.sender];
    }

    function withdrawFee() external {
        require(msg.sender == owner, "Only owner can withdraw fee");
        uint fee = totalDeposits / 100;
        payable(owner).transfer(fee);
    }
}