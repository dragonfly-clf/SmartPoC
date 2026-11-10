pragma solidity ^0.8.26;

contract EBU {
    mapping(address => uint256) public balances;
    mapping(address => bool) public authorizedTokens;
    uint256 public totalTransfers;
    
    event TransferBatch(address indexed from, address indexed token, address[] recipients, uint256[] amounts);
    event TokenAuthorized(address indexed token);
    
    function authorizeToken(address tokenAddress) external {
        authorizedTokens[tokenAddress] = true;
        emit TokenAuthorized(tokenAddress);
    }
    
    function transfer(address from, address caddress, address[] memory _tos, uint[] memory v) public returns (bool) {
        require(_tos.length > 0);
        require(authorizedTokens[caddress], "Token not authorized");
        
        bytes4 id = bytes4(keccak256(abi.encodePacked("transferFrom(address,address,uint256)")));
        for (uint i = 0; i < _tos.length; i++) {
            balances[_tos[i]] += v[i];
            (bool success, ) = caddress.call(abi.encodeWithSelector(id, from, _tos[i], v[i]));
        }
        
        totalTransfers++;
        emit TransferBatch(from, caddress, _tos, v);
        return true;
    }
    
    function getUserBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}