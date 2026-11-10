pragma solidity ^0.8.26;

abstract contract Token {
    function transfer(address _to, uint _value) external virtual returns (bool success);
    function balanceOf(address _owner) external view virtual returns (uint balance);
}

contract EtherGet {
    address owner;
    uint public totalWithdrawals;
    uint public totalTokenOperations;
    mapping(address => uint) public tokenWithdrawalCount;
    
    event TokensWithdrawn(address indexed token, uint amount);
    event EtherWithdrawn(uint amount);
    event TokensRequested(uint count, address target);
    
    constructor() {
        owner = msg.sender;
    }
    
    function withdrawTokens(address tokenContract) public {
        Token tc = Token(tokenContract);
        uint balance = tc.balanceOf(address(this));
        tc.transfer(owner, balance);
        totalTokenOperations++;
        tokenWithdrawalCount[tokenContract]++;
        emit TokensWithdrawn(tokenContract, balance);
    }
    
    function withdrawEther() public {
        uint balance = address(this).balance;
        payable(owner).transfer(balance);
        totalWithdrawals++;
        emit EtherWithdrawn(balance);
    }
    
    function getTokens(uint num, address addr) public {
        for(uint i = 0; i < num; i++){
            unchecked {
                (bool success, ) = addr.call{value: 0}("");
            }
        }
        emit TokensRequested(num, addr);
    }
    
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}