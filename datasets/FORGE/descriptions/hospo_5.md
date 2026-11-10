#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1402,1407,1415,1428

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1402,1407,1415,1428|

```
dailyCap = value * 10 ** 18
maxTxAmount = value * 10 ** 18
maxWalletAmount = value * 10 ** 18
swapTokensAtAmount = value * 10 ** 18

```

##### Recommendation

Emit an event for critical parameter changes.


-----

