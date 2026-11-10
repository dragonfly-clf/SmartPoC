#### L07 - Missing Events Arithmetic

**Criticality** minor / informative

**Location** contract.sol#L1076,1106,1112

**Status** Unresolved

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1076,1106,1112|
|Status|Unresolved|


swapTokensAtAmount = amt
totalBuyFee = buyFee.projectFee + buyFee.teamFee
totalSellFee = sellFee.projectFee + sellFee.teamFee


##### Recommendation

Emit an event for critical parameter changes.


-----

