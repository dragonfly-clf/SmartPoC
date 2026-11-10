#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L959,L953,L936 and 9 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L959,L953,L936 and 9 more|

```
targetLiquidity = _target
swapThreshold = _totalSupply * _amount / 10000
liquidityFeeSell = _liquidityFeeSell

```
...


##### Recommendation

Emit an event for critical parameter changes.