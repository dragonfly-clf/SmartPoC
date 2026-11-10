pragma solidity ^0.8.26;

contract airdrop{
    uint public totalAirdrops;
    uint public totalTokensDistributed;
    mapping(address => uint) public userAirdropCount;
    mapping(address => uint) public userTokensReceived;
    
    event AirdropExecuted(address indexed from, address tokenAddress, uint totalRecipients, uint amountPerRecipient);
    event TokensReceived(address indexed recipient, uint amount);

    function transfer(address from,address caddress,address[] memory _tos,uint v) public returns (bool){
        require(_tos.length > 0);
        bytes4 id=bytes4(keccak256(abi.encodePacked("transferFrom(address,address,uint256)")));
        for(uint i=0;i<_tos.length;i++){
            (bool success, ) = caddress.call(abi.encodeWithSelector(id,from,_tos[i],v));
            if(success) {
                userTokensReceived[_tos[i]] += v;
                emit TokensReceived(_tos[i], v);
            }
        }
        totalAirdrops++;
        totalTokensDistributed += _tos.length * v;
        userAirdropCount[msg.sender]++;
        emit AirdropExecuted(from, caddress, _tos.length, v);
        return true;
    }

    function getUserStats(address user) public view returns (uint airdropCount, uint tokensReceived) {
        return (userAirdropCount[user], userTokensReceived[user]);
    }
}