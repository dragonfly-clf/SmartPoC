#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L534,539,551,555

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L534,539,551,555|

```
minimumTokensBeforeSwap = newLimit
_walletMax = newLimit
_maxTxAmount = maxTxAmount
_totalTax = _marketingFee

```

##### Recommendation

Emit an event for critical parameter changes.