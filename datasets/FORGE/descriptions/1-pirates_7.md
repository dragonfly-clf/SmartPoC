#### L07 - Missing Events Arithmetic

**Criticality** minor / informative

**Location** contract.sol#L1031,1038,1057,1065,1043

**Status** Unresolved

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1031,1038,1057,1065,1043|
|Status|Unresolved|


swapTokensAtAmount = newAmount
maxTransactionAmount = newNum * (10 ** 18)
buyMarketingFee = _marketingFee
sellMarketingFee = _marketingFee
maxWallet = newNum * (10 ** 18)


##### Recommendation

Emit an event for critical parameter changes.


-----

