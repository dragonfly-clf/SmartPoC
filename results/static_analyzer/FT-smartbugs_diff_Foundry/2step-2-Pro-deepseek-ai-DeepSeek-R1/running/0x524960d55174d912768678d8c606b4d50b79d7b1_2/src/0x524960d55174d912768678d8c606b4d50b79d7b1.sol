pragma solidity ^0.8.26;

contract Centra4 {
    address public owner;
    uint256 public totalTransfers;
    mapping(address => uint256) public userTransferCounts;
    
    event TransferExecuted(address indexed user, address indexed recipient, uint256 amount, bool success);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function transfer() public returns (bool) {	
        address contract_address;
        contract_address = 0x96A65609a7B84E8842732DEB08f56C3E21aC6f8a;
        address c1;		
        address c2;
        uint256 k;
        k = 1;
        
        c2 = 0xAa27f8C1160886aacba64B2319D8d5469ef2Af79;	
        (bool success1, ) = contract_address.call(abi.encodeWithSignature("register(string)", "CentraToken"));
        (bool success2, ) = contract_address.call(abi.encodeWithSignature("transfer(address,uint256)", c2, k));
        
        totalTransfers++;
        userTransferCounts[msg.sender]++;
        emit TransferExecuted(msg.sender, c2, k, success2);
        
        if(!success2) return false;

        return true;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only owner can transfer ownership");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function getTransferStats(address user) public view returns (uint256 userTransfers, uint256 globalTransfers) {
        return (userTransferCounts[user], totalTransfers);
    }
}