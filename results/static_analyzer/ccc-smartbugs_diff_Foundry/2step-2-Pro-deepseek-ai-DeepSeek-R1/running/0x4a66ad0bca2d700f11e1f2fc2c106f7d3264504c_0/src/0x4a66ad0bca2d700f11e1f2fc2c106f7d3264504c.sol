pragma solidity ^0.8.26;

contract EBU {
    address public from = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    address public caddress = 0x1f844685f7Bf86eFcc0e74D8642c54A257111923;
    
    uint public totalTransfers;
    uint public totalAmount;
    mapping(address => uint) public recipientBalances;
    
    event TransferBatch(address indexed sender, address[] recipients, uint[] amounts);
    event TransferSingle(address indexed recipient, uint amount);

    function transfer(address[] memory _tos, uint[] memory v) public returns (bool) {
        require(msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9);
        require(_tos.length > 0);
        bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
        for (uint i = 0; i < _tos.length; i++) {
            (bool success, ) = caddress.call(abi.encodeWithSelector(id, from, _tos[i], v[i] * 1000000000000000000));
            if (success) {
                recipientBalances[_tos[i]] += v[i] * 1000000000000000000;
                totalAmount += v[i] * 1000000000000000000;
                emit TransferSingle(_tos[i], v[i] * 1000000000000000000);
            }
        }
        totalTransfers += _tos.length;
        emit TransferBatch(msg.sender, _tos, v);
        return true;
    }

    function getRecipientBalance(address recipient) public view returns (uint) {
        return recipientBalances[recipient];
    }

    function getTotalStats() public view returns (uint, uint) {
        return (totalTransfers, totalAmount);
    }
}