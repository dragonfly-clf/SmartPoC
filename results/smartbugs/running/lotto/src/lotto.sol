pragma solidity ^0.8.26;

contract Lotto {
    bool public payedOut = false;
    address public winner;
    uint public winAmount;
    uint public ticketPrice = 0.1 ether;
    uint public totalTickets;
    mapping(address => uint) public ticketsBought;
    
    event TicketPurchased(address indexed buyer, uint amount);
    event WinnerPaid(address indexed winner, uint amount);
    event LeftoverWithdrawn(address indexed withdrawer, uint amount);

    function buyTicket() public payable {
        require(msg.value == ticketPrice, "Must pay exact ticket price");
        totalTickets++;
        ticketsBought[msg.sender]++;
        emit TicketPurchased(msg.sender, msg.value);
    }

    function setWinner(address _winner, uint _winAmount) public {
        winner = _winner;
        winAmount = _winAmount;
    }

    function sendToWinner() public {
        require(!payedOut);
        payable(winner).send(winAmount);
        payedOut = true;
        emit WinnerPaid(winner, winAmount);
    }

    function withdrawLeftOver() public {
        require(payedOut);
        payable(msg.sender).send(address(this).balance);
        emit LeftoverWithdrawn(msg.sender, address(this).balance);
    }
}