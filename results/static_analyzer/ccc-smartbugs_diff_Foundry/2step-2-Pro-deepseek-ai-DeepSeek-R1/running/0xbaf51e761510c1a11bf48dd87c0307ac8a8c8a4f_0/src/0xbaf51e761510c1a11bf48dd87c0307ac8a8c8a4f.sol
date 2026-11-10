/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 41
 */

pragma solidity ^0.8.26;

contract ETH_VAULT
{
    mapping (address => uint) public balances;
    
    uint public MinDeposit = 1 ether;
    
    Log TransferLog;
    
    constructor(address _log)
    {
        TransferLog = Log(_log);
    }
    
    function Deposit()
    public
    payable
    {
        if(msg.value > MinDeposit)
        {
            unchecked {
                balances[msg.sender] += msg.value;
            }
            TransferLog.AddMessage(msg.sender,msg.value,"Deposit");
        }
    }
    
    function CashOut(uint _am)
    public
    payable
    {
        if(_am<=balances[msg.sender])
        {
            // <yes> <report> REENTRANCY
            (bool success, ) = payable(msg.sender).call{value: _am}("");
            if(success)
            {
                unchecked {
                    balances[msg.sender] -= _am;
                }
                TransferLog.AddMessage(msg.sender,_am,"CashOut");
            }
        }
    }
    
    fallback() external payable{}    
    receive() external payable{}
}

contract Log 
{
   
    struct Message
    {
        address Sender;
        string  Data;
        uint Val;
        uint  Time;
    }
    
    Message[] public History;
    
    Message LastMsg;
    
    function AddMessage(address _adr,uint _val,string memory _data)
    public
    {
        LastMsg.Sender = _adr;
        LastMsg.Time = block.timestamp;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}