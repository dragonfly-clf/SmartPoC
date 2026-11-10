pragma solidity ^0.8.26;

contract IntegerOverflowMul {
    uint public count = 2;
    uint public totalOperations;
    mapping(address => uint) public userOperations;
    address public owner;

    event OperationPerformed(address indexed user, uint input, uint result);

    constructor() {
        owner = msg.sender;
    }

    function run(uint256 input) public {
        unchecked {
            uint oldCount = count;
            count *= input;
            totalOperations++;
            userOperations[msg.sender]++;
            emit OperationPerformed(msg.sender, input, count);
        }
    }

    function resetCount() public {
        require(msg.sender == owner, "Only owner can reset");
        count = 2;
    }
}