pragma solidity ^0.8.26;

contract IntegerOverflowMappingSym1 {
    mapping(uint256 => uint256) map;
    uint256 public totalOperations;
    uint256 public lastOperationTime;
    mapping(address => uint256) public userOperations;
    
    event OperationPerformed(address indexed user, uint256 key, uint256 value, uint256 timestamp);

    function init(uint256 k, uint256 v) public {
        unchecked {
            map[k] -= v;
        }
        
        totalOperations++;
        lastOperationTime = block.timestamp;
        userOperations[msg.sender]++;
        
        emit OperationPerformed(msg.sender, k, v, block.timestamp);
    }

    function getUserOperationCount(address user) public view returns (uint256) {
        return userOperations[user];
    }

    function getMapValue(uint256 key) public view returns (uint256) {
        return map[key];
    }
}