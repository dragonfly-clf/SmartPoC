pragma solidity ^0.8.26;

contract Map {
    address public owner;
    uint256[] map;
    uint256 public totalStorageOperations;
    uint256 public totalWithdrawals;
    mapping(address => uint256) public userStorageCount;

    event ValueStored(address indexed user, uint256 key, uint256 value);
    event Withdrawal(address indexed owner, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function set(uint256 key, uint256 value) public {
        if (map.length <= key) {
            uint256[] memory newMap = new uint256[](key + 1);
            for (uint256 i = 0; i < map.length; i++) {
                newMap[i] = map[i];
            }
            map = newMap;
        }
        map[key] = value;
        totalStorageOperations++;
        userStorageCount[msg.sender]++;
        emit ValueStored(msg.sender, key, value);
    }

    function get(uint256 key) public view returns (uint256) {
        return map[key];
    }

    function withdraw() public {
        require(msg.sender == owner);
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        totalWithdrawals++;
        emit Withdrawal(msg.sender, balance);
    }

    function deposit() external payable {
        // Simple deposit function to add funds to contract
    }
}