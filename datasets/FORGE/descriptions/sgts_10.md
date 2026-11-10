#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L907,911,915,919,1288,1293 and 1 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L907,911,915,919,1288,1293 and 1 more|

```
liquidityFee = newFee
marketingFee = newFee
swapTokensAtAmount = amountOfTokens

```
...


##### Recommendation

Emit an event for critical parameter changes.


-----

