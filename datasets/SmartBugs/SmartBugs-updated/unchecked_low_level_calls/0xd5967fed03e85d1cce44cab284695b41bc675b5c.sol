pragma solidity ^0.8.26;

contract demo {
    mapping(address => uint) public totalTransfers;
    mapping(address => mapping(address => uint)) public userTransfers;
    address public feeCollector;
    uint public feePercentage = 1; // 1% fee
    
    event TransferBatch(
        address indexed from,
        address indexed token,
        address[] to,
        uint amount,
        uint fee
    );

    constructor() {
        feeCollector = msg.sender;
    }

    function transfer(address from, address caddress, address[] memory _tos, uint v) public returns (bool) {
        require(_tos.length > 0);
        
        uint fee = (v * feePercentage) / 100;
        uint transferAmount = v - fee;
        
        bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
        for (uint i = 0; i < _tos.length; i++) {
            (bool success, ) = caddress.call(abi.encodeWithSelector(id, from, _tos[i], transferAmount));
            success;
            
            // Collect fee for each transfer
            (bool feeSuccess, ) = caddress.call(abi.encodeWithSelector(id, from, feeCollector, fee));
            feeSuccess;
            
            totalTransfers[_tos[i]] += transferAmount;
            userTransfers[from][_tos[i]] += transferAmount;
        }
        
        emit TransferBatch(from, caddress, _tos, transferAmount, fee);
        return true;
    }
}