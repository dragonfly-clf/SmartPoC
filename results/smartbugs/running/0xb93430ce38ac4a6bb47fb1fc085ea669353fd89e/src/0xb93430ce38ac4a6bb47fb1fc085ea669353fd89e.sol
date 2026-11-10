pragma solidity ^0.8.26;

contract PrivateBank {
    mapping(address => uint256) public balances;
    
    uint256 public MinDeposit = 1 ether;
    
    Log TransferLog;
    
    constructor(address _lib) {
        TransferLog = Log(_lib);
    }
    
    function Deposit() public payable {
        if(msg.value >= MinDeposit) {
            unchecked {
                balances[msg.sender] += msg.value;
            }
            TransferLog.AddMessage(msg.sender, msg.value, "Deposit");
        }
    }
    
    function CashOut(uint256 _am) public {
        if(_am <= balances[msg.sender]) {
            (bool success, ) = payable(msg.sender).call{value: _am}("");
            if(success) {
                unchecked {
                    balances[msg.sender] -= _am;
                }
                TransferLog.AddMessage(msg.sender, _am, "CashOut");
            }
        }
    }
    
    fallback() external payable {}
}

contract Log {
    struct Message {
        address Sender;
        string Data;
        uint256 Val;
        uint256 Time;
    }
    
    Message[] public History;
    
    Message public LastMsg;
    
    function AddMessage(address _adr, uint256 _val, string memory _data) public {
        LastMsg.Sender = _adr;
        LastMsg.Time = block.timestamp;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}