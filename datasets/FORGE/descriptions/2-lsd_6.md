#### L07 - Missing Events Arithmetic

**Criticality** minor / informative

**Location** contract.sol#L1213,905,883

**Status** Unresolved

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1213,905,883|
|Status|Unresolved|


killNum = killNumber
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 2)
ReflectionFee = _ReflectionFee


##### Recommendation

Emit an event for critical parameter changes.


-----

