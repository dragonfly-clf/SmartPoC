/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 44
 */

pragma solidity ^0.8.26;

contract ETH_FUND
{
    mapping (address => uint) public balances;
    
    uint public MinDeposit = 1 ether;
    
    Log TransferLog;
    
    uint lastBlock;
    
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
            TransferLog.AddMessage(msg.sender, msg.value, "Deposit");
            lastBlock = block.number;
        }
    }
    
    function CashOut(uint _am)
    public
    payable
    {
        if(_am <= balances[msg.sender] && block.number > lastBlock)
        {
            // <yes> <report> REENTRANCY
            (bool success, ) = payable(msg.sender).call{value: _am}("");
            if(success)
            {
                unchecked {
                    balances[msg.sender] -= _am;
                }
                TransferLog.AddMessage(msg.sender, _am, "CashOut");
            }
        }
    }
    
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
    
    function AddMessage(address _adr, uint _val, string memory _data)
    public
    {
        LastMsg.Sender = _adr;
        LastMsg.Time = block.timestamp;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}