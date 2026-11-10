#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1392,1403,1421

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1392,1403,1421|

```
swapTokensAtAmount = amount
SELLBNBRewardsFee = newRewardFee
BUYBNBRewardsFee = newRewardFee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

