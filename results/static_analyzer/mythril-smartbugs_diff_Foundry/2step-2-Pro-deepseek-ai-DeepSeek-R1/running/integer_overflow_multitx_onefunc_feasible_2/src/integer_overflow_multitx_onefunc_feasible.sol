pragma solidity ^0.8.26;

contract IntegerOverflowMultiTxOneFuncFeasible {
    uint256 private initialized = 0;
    uint256 public count = 1;
    address public owner;
    mapping(address => uint256) public userBalances;
    uint256 public totalOperations;
    
    event BalanceUpdated(address indexed user, uint256 newBalance);
    event OperationPerformed(address indexed user, uint256 input);

    constructor() {
        owner = msg.sender;
    }

    function run(uint256 input) public {
        if (initialized == 0) {
            initialized = 1;
            return;
        }
        
        totalOperations++;
        emit OperationPerformed(msg.sender, input);
        
        unchecked {
            count -= input;
        }
        
        userBalances[msg.sender] = count;
        emit BalanceUpdated(msg.sender, count);
    }

    function getUserBalance(address user) public view returns (uint256) {
        return userBalances[user];
    }
}