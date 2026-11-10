#### L07 - Missing Events Arithmetic

**Criticality** minor / informative

**Location** contract.sol#L473,465

**Status** Unresolved

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L473,465|
|Status|Unresolved|


liquidityFee = _liquidityFee
sellMultiplier = _sell


##### Recommendation

Emit an event for critical parameter changes.


-----

