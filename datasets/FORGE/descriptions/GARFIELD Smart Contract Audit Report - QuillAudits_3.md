3. time variable is not validated

 Description The _lockTime is set by the owner via the lock() function, where _lockTime = now + time;. According to the condition set in the require() within unlock() function, the contract should be locked until 7 days.

 L477: require(now > _lockTime , "Contract is locked until 7 days");

 Unfortunately, the time variable can be set to an arbitrary number by the owner, which helps the _lockTime variable bypass the condition in the unlock() function.

 0506


-----

|Weak PRNG|Col2|
|---|---|
|Line|Code|
|693 function random(uint256 from, uint256 to, uint256 salty) private view returns (uint256) { uint256 seed = uint256( keccak256( abi.encodePacked( block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) + block.number + salty ) ) ); return seed.mod(to - from) + from; }||


###### Remediation We recommend adding a check for the time parameter, where the time should be validated corresponding to the condition of the unlock() function.

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit f5b0e4d88928ab05c42ed764bb09dec3d7a71fc5

 