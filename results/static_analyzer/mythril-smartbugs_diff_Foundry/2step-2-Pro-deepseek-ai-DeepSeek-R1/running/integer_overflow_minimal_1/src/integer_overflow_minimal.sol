pragma solidity ^0.8.26;

contract IntegerOverflowMinimal {
    uint public count = 1;
    mapping(address => uint) public userBalances;
    uint public totalOperations;

    event BalanceUpdated(address indexed user, uint newBalance);
    event OperationPerformed(address indexed user, uint input);

    function run(uint256 input) public {
        unchecked {
            count -= input;
        }
        
        userBalances[msg.sender] = count;
        totalOperations++;
        
        emit BalanceUpdated(msg.sender, count);
        emit OperationPerformed(msg.sender, input);
    }

    function getUserBalance(address user) public view returns (uint) {
        return userBalances[user];
    }

    function resetCount() public {
        count = 1;
        totalOperations = 0;
    }
}