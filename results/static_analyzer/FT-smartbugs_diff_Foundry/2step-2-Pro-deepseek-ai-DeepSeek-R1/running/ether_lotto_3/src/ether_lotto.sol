pragma solidity ^0.8.26;

contract EtherLotto {
    uint constant TICKET_AMOUNT = 10;
    uint constant FEE_AMOUNT = 1;
    address public bank;
    uint public pot;
    uint public totalGames;
    uint public totalWinners;
    mapping(address => uint) public playerWins;
    
    event GamePlayed(address indexed player, bool won, uint prize);
    event FundsAdded(address indexed depositor, uint amount);

    constructor() {
        bank = msg.sender;
    }

    function addToPot() external payable {
        pot += msg.value;
        emit FundsAdded(msg.sender, msg.value);
    }

    function play() public payable {
        assert(msg.value == TICKET_AMOUNT);
        unchecked {
            pot += msg.value;
        }
        totalGames++;
        
        unchecked {
            uint random = uint(keccak256(abi.encodePacked(block.timestamp))) % 2;
            if (random == 0) {
                payable(bank).transfer(FEE_AMOUNT);
                uint prize = pot - FEE_AMOUNT;
                payable(msg.sender).transfer(prize);
                totalWinners++;
                playerWins[msg.sender]++;
                pot = 0;
                emit GamePlayed(msg.sender, true, prize);
            } else {
                emit GamePlayed(msg.sender, false, 0);
            }
        }
    }

    function withdrawBankFee() external {
        require(msg.sender == bank, "Only bank can withdraw fee");
        uint feeBalance = address(this).balance - pot;
        payable(bank).transfer(feeBalance);
    }
}