4. Weak PRNG

 Line Code

 693 function random(uint256 from, uint256 to, uint256 salty) private view returns (uint256) {     uint256 seed = uint256( keccak256( abi.encodePacked( block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) + block.number + salty ) )     );     return seed.mod(to - from) + from;   }

 Description Weak PRNG due to a modulo on block.timestamp, now, block.difficulty, block.number and block.gaslimit. These can be influenced by miners to some extent so they should be avoided.

 Furthermore, the to and from parameters are hard-coded and the salty parameter is set to the balance of the msg.sender. 

 Remediation The Auditee should write smart contracts with the notion that block values are not precise, and the use of them can lead to unexpected effects. Alternatively, the Auditee may make use of oracles.

 0507


-----

###### .References

 Safety: Timestamp dependence Ethereum Smart Contract Best Practices - Timestamp Dependence How do Ethereum mining nodes maintain a time consistent with the network? Solidity: Timestamp dependency, is it possible to do safely? Avoid using block.number as a timestamp

 Status: Acknowledged by the Auditee Even though the fix does not make use of Oracle's solution, the Garfield team made some fixes based on our recommendations by removing block and transaction properties. We address below the fixes introduced up to commit b0347563f3a41bab060921709251a33dd69201d9

#### 