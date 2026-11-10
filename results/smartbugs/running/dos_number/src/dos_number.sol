pragma solidity ^0.8.26;

contract DosNumber {
    uint numElements = 0;
    uint[] array;
    
    address public owner;
    uint public totalInserts;
    uint public totalClears;
    mapping(address => uint) public userInsertCount;
    
    event NumbersInserted(address indexed user, uint value, uint count);
    event ArrayCleared(address indexed clearer, uint elementsCleared);

    constructor() {
        owner = msg.sender;
    }

    function insertNnumbers(uint value, uint numbers) public {
        for (uint i = 0; i < numbers; i++) {
            unchecked {
                if (numElements == array.length) {
                    array.push();
                }
                array[numElements++] = value;
            }
        }
        totalInserts += numbers;
        userInsertCount[msg.sender] += numbers;
        emit NumbersInserted(msg.sender, value, numbers);
    }

    function clear() public {
        require(numElements > 1500);
        numElements = 0;
        totalClears++;
        emit ArrayCleared(msg.sender, numElements);
    }

    function clearDOS() public {
        require(numElements > 1500);
        array = new uint[](0);
        numElements = 0;
        totalClears++;
        emit ArrayCleared(msg.sender, numElements);
    }

    function getLengthArray() public view returns (uint) {
        return numElements;
    }

    function getRealLengthArray() public view returns (uint) {
        return array.length;
    }

    function getUserStats(address user) public view returns (uint inserts, uint arrayLength) {
        return (userInsertCount[user], array.length);
    }
}