#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L831,837,843

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L831,837,843|

```
liquiditySwap = liquidity
sellTotalFees = dev.add(liquidity)
buyTotalFees = dev.add(liquidity)

```

##### Recommendation

Emit an event for critical parameter changes.