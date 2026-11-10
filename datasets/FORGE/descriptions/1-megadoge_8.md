#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1584,1591,1643,1715

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1584,1591,1643,1715|

```
maxTxAmount = Amount * 10 ** 9
swapTokensAtAmount = amount
marketingFee = value

```
...


##### Recommendation

Emit an event for critical parameter changes.


-----

