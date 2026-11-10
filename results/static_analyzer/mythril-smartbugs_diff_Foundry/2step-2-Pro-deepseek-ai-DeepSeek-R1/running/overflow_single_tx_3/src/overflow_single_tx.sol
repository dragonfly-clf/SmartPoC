pragma solidity ^0.8.26;

contract IntegerOverflowSingleTransaction {
    uint public count = 1;
    address public owner;
    uint public totalOperations;
    mapping(address => uint) public userOperations;
    
    event OperationPerformed(address indexed user, string operationType, uint input, uint newCount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function overflowaddtostate(uint256 input) public {
        unchecked { count += input; }
        totalOperations++;
        userOperations[msg.sender]++;
        emit OperationPerformed(msg.sender, "add", input, count);
    }

    function overflowmultostate(uint256 input) public {
        unchecked { count *= input; }
        totalOperations++;
        userOperations[msg.sender]++;
        emit OperationPerformed(msg.sender, "multiply", input, count);
    }

    function underflowtostate(uint256 input) public {
        unchecked { count -= input; }
        totalOperations++;
        userOperations[msg.sender]++;
        emit OperationPerformed(msg.sender, "subtract", input, count);
    }

    function overflowlocalonly(uint256 input) public {
        unchecked { uint res = count + input; }
        totalOperations++;
        userOperations[msg.sender]++;
        emit OperationPerformed(msg.sender, "local_add", input, count);
    }

    function overflowmulocalonly(uint256 input) public {
        unchecked { uint res = count * input; }
        totalOperations++;
        userOperations[msg.sender]++;
        emit OperationPerformed(msg.sender, "local_multiply", input, count);
    }

    function underflowlocalonly(uint256 input) public {
        unchecked { uint res = count - input; }
        totalOperations++;
        userOperations[msg.sender]++;
        emit OperationPerformed(msg.sender, "local_subtract", input, count);
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only owner can transfer ownership");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function resetCounter() public {
        require(msg.sender == owner, "Only owner can reset counter");
        count = 1;
    }
}