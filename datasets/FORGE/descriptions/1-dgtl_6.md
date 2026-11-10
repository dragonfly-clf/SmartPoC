#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L316,780,742,765,725,785,716

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L316,780,742,765,725,785,716|


autoBuybackCap = _cap
targetLiquidity = _target
buybackMultiplierNumerator = numerator
liquidityFee = _liquidityFee
_maxTxAmount = amount
swapThreshold = _amount
minPeriod = _minPeriod


##### Recommendation

Emit an event for critical parameter changes.


-----

