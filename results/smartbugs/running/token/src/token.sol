pragma solidity ^0.8.26;

contract Token {
    mapping(address => uint) balances;
    uint public totalSupply;
    address public owner;
    uint public totalTransfers;
    mapping(address => uint) public transferCounts;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(uint _initialSupply) {
        balances[msg.sender] = totalSupply = _initialSupply;
        owner = msg.sender;
    }

    function transfer(address _to, uint _value) public returns (bool) {
        unchecked {
            require(balances[msg.sender] - _value >= 0);
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }
        totalTransfers++;
        transferCounts[msg.sender]++;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only owner can transfer ownership");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function mint(uint amount) public {
        require(msg.sender == owner, "Only owner can mint");
        balances[owner] += amount;
        totalSupply += amount;
    }
}