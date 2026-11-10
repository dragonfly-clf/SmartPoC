pragma solidity ^0.8.26;

contract Missing{
    address private owner;
    uint public totalDeposits;
    mapping(address => uint) public userBalances;
    
    modifier onlyowner {
        require(msg.sender==owner);
        _;
    }

    function Constructor()
        public
    {
        owner = msg.sender;
    }

    receive() external payable {
        totalDeposits += msg.value;
        userBalances[msg.sender] += msg.value;
    }

    function withdraw()
        public
        onlyowner
    {
       payable(owner).transfer(address(this).balance);
    }
    
    function getUserBalance(address user) public view returns (uint) {
        return userBalances[user];
    }
}