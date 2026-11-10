pragma solidity ^0.8.26;

contract Unprotected {
    address private owner;
    uint256 public totalOwnershipChanges;
    mapping(address => uint256) public ownershipChangesByAddress;
    
    event OwnershipChanged(address indexed previousOwner, address indexed newOwner, uint256 timestamp);

    modifier onlyowner {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
        totalOwnershipChanges = 0;
    }

    function changeOwner(address _newOwner) public {
        address previousOwner = owner;
        owner = _newOwner;
        totalOwnershipChanges++;
        ownershipChangesByAddress[_newOwner]++;
        emit OwnershipChanged(previousOwner, _newOwner, block.timestamp);
    }

    function getOwnerBalance() public view onlyowner returns (uint256) {
        return owner.balance;
    }

    function recordOwnershipActivity() public onlyowner {
        totalOwnershipChanges++;
    }
}