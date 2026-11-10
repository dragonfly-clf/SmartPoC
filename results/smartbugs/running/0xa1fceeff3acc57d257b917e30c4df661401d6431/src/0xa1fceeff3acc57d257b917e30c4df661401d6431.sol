pragma solidity ^0.8.26;

contract AirDropContract{
    uint public totalAirdrops;
    uint public totalTokensDistributed;
    mapping(address => uint) public userAirdropCount;
    mapping(address => uint) public tokensReceived;

    event AirdropExecuted(address indexed contractAddress, address indexed sender, uint totalRecipients, uint totalAmount);
    event TokensReceived(address indexed recipient, uint amount);

    constructor() {
    }

    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }
    
    function transfer(address contract_address,address[] calldata tos,uint[] calldata vs)
        public 
        validAddress(contract_address)
        returns (bool){

        require(tos.length > 0);
        require(vs.length > 0);
        require(tos.length == vs.length);
        
        uint totalAmount = 0;
        for(uint i = 0; i < vs.length; i++) {
            totalAmount += vs[i];
        }
        
        bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint i = 0 ; i < tos.length; i++){
            (bool success, ) = contract_address.call(abi.encodeWithSelector(id, msg.sender, tos[i], vs[i]));
            if(success) {
                tokensReceived[tos[i]] += vs[i];
                userAirdropCount[tos[i]]++;
                emit TokensReceived(tos[i], vs[i]);
            }
        }
        
        totalAirdrops++;
        totalTokensDistributed += totalAmount;
        emit AirdropExecuted(contract_address, msg.sender, tos.length, totalAmount);
        
        return true;
    }
    
    function getUserStats(address user) public view returns (uint airdropCount, uint totalTokens) {
        return (userAirdropCount[user], tokensReceived[user]);
    }
}