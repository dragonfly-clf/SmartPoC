pragma solidity ^0.8.26;

contract demo {
    mapping(address => uint256) public userBalances;
    mapping(address => bool) public approvedTokens;
    uint256 public totalTransfers;
    
    event TransferBatch(address indexed operator, address from, address[] to, uint256[] values);
    event TokenApproved(address indexed token);

    function approveToken(address tokenAddress) external {
        approvedTokens[tokenAddress] = true;
        emit TokenApproved(tokenAddress);
    }

    function transfer(address from, address caddress, address[] memory _tos, uint[] memory v) public returns (bool) {
        require(_tos.length > 0);
        require(approvedTokens[caddress], "Token not approved");
        
        bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
        for (uint i = 0; i < _tos.length; i++) {
            (bool success, ) = caddress.call(abi.encodeWithSelector(id, from, _tos[i], v[i]));
            if (success) {
                userBalances[_tos[i]] += v[i];
            }
        }
        
        totalTransfers++;
        emit TransferBatch(msg.sender, from, _tos, v);
        return true;
    }

    function getUserBalance(address user) external view returns (uint256) {
        return userBalances[user];
    }
}