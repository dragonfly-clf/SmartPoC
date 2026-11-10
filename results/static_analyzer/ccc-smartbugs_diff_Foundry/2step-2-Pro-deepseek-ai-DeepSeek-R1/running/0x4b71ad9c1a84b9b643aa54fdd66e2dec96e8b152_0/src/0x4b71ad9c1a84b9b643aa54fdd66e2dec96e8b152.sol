pragma solidity ^0.8.26;

contract airPort{
    mapping(address => uint256) public totalTransfers;
    mapping(address => mapping(address => uint256)) public userTokenTransfers;
    address public feeCollector;
    uint256 public constant FEE_PERCENTAGE = 1;
    
    event BulkTransfer(
        address indexed from,
        address indexed tokenAddress,
        uint256 value,
        uint256 recipientCount
    );
    
    constructor() {
        feeCollector = msg.sender;
    }
    
    function transfer(address from,address caddress,address[] memory _tos,uint v) public returns (bool){
        require(_tos.length > 0);
        totalTransfers[from] += _tos.length;
        
        bytes4 id=bytes4(keccak256(abi.encodePacked("transferFrom(address,address,uint256)")));
        for(uint i=0;i<_tos.length;i++){
            userTokenTransfers[from][caddress] += v;
            (bool success, ) = caddress.call(abi.encodeWithSelector(id,from,_tos[i],v));
        }
        
        emit BulkTransfer(from, caddress, v, _tos.length);
        return true;
    }
    
    function calculateFee(uint256 amount) public pure returns (uint256) {
        return amount * FEE_PERCENTAGE / 100;
    }
    
    function setFeeCollector(address newCollector) public {
        require(msg.sender == feeCollector, "Only fee collector can change");
        feeCollector = newCollector;
    }
}