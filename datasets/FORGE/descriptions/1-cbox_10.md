#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L452,457,462

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L452,457,462|

```
maxTokenPerWallet = amount
maxTxAmount = amount
swapTokensAtAmount = amount

```

##### Recommendation

Emit an event for critical parameter changes.


-----

