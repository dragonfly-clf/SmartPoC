pragma solidity ^0.8.26;

contract IntegerOverflowMultiTxMultiFuncFeasible {
    uint256 private initialized = 0;
    uint256 public count = 1;
    address public owner;
    uint256 public totalOperations;
    mapping(address => uint256) public userOperations;

    event OperationPerformed(address indexed user, uint256 input, uint256 newCount);
    event ContractInitialized(address indexed initializer);

    constructor() {
        owner = msg.sender;
    }

    function init() public {
        require(initialized == 0, "Already initialized");
        initialized = 1;
        emit ContractInitialized(msg.sender);
    }

    function run(uint256 input) public {
        if (initialized == 0) {
            return;
        }
        
        totalOperations++;
        userOperations[msg.sender]++;
        
        unchecked {
            count -= input;
        }
        
        emit OperationPerformed(msg.sender, input, count);
    }

    function resetCount() public {
        require(msg.sender == owner, "Only owner can reset");
        count = 1;
    }
}