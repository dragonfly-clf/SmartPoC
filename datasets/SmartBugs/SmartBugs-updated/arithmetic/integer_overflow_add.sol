pragma solidity ^0.8.26;

contract IntegerOverflowAdd {
    uint public count = 1;
    uint public totalOperations;
    mapping(address => uint) public userOperations;
    
    event OperationPerformed(address indexed user, uint input, uint newCount);
    event BalanceChecked(address indexed user, uint balance);

    function run(uint256 input) public {
        unchecked {
            count += input;
        }
        totalOperations++;
        userOperations[msg.sender]++;
        emit OperationPerformed(msg.sender, input, count);
    }

    function checkBalance() public {
        emit BalanceChecked(msg.sender, address(this).balance);
    }

    function getUserOperationCount(address user) public view returns (uint) {
        return userOperations[user];
    }
}