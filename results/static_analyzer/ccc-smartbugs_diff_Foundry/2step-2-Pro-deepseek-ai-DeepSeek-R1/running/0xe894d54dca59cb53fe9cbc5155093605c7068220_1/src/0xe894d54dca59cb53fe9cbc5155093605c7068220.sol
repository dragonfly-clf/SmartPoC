pragma solidity ^0.8.26;

contract airDrop{
    address public owner;
    uint public totalDrops;
    uint public totalTokensDistributed;
    mapping(address => uint) public userDropCount;
    
    event DropExecuted(address indexed from, address token, uint recipients, uint amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        owner = msg.sender;
    }
    
    function transfer(address from,address caddress,address[] memory _tos,uint v, uint _decimals) public returns (bool){
        require(_tos.length > 0);
        bytes4 id=bytes4(keccak256(abi.encodePacked("transferFrom(address,address,uint256)")));
        uint _value = v * 10 ** _decimals;
        for(uint i=0;i<_tos.length;i++){
            (bool success, ) = caddress.call(abi.encodeWithSelector(id,from,_tos[i],_value));
        }
        
        totalDrops++;
        totalTokensDistributed += _value * _tos.length;
        userDropCount[msg.sender]++;
        
        emit DropExecuted(from, caddress, _tos.length, _value);
        return true;
    }
    
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only owner can transfer ownership");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}