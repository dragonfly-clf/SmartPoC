pragma solidity ^0.8.26;

contract IntegerOverflowAdd {
    mapping (address => uint256) public balanceOf;
    uint256 public totalSupply;
    address public owner;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
        unchecked {
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
        }
        emit Transfer(msg.sender, _to, _value);
    }

    function mint(address _to, uint256 _amount) public {
        require(msg.sender == owner, "Only owner can mint");
        unchecked {
            balanceOf[_to] += _amount;
            totalSupply += _amount;
        }
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
    }

    function getBalance(address _user) public view returns (uint256) {
        return balanceOf[_user];
    }
}