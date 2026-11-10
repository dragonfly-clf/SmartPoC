#### STC - Succeeded Transfer Check

**Criticality** minor / informative

**Location** contract.sol#L358

**Status** Unresolved

##### Description

According to the ERC20 specification, the transfer methods should be checked if
the result is successful. Otherwise, the contract may wrongly assume that the
transfer has been established.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L358|
|Status|Unresolved|


return BEP20(tokenAddress).transfer(msg.sender, tokens);


##### Recommendation

The contract should check if the result of the transfer methods is successful.


-----

