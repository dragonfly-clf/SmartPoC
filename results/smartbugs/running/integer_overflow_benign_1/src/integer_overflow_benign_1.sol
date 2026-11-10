pragma solidity ^0.8.26;

contract IntegerOverflowBenign1 {
    uint public count = 1;
    uint public totalOperations;
    mapping(address => uint) public userOperations;
    
    event OperationPerformed(address indexed user, uint input, uint timestamp);
    
    function run(uint256 input) public {
        unchecked {
            uint res = count - input;
        }
        
        totalOperations++;
        userOperations[msg.sender]++;
        emit OperationPerformed(msg.sender, input, block.timestamp);
    }
    
    function getUserOperationCount(address user) public view returns (uint) {
        return userOperations[user];
    }
    
    function resetUserOperations() public {
        userOperations[msg.sender] = 0;
    }
}