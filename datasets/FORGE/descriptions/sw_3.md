#### L07 - Missing Events Arithmetic

**Criticality** minor / informative

**Location** contract.sol#L787,783

**Status** Unresolved

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L787,783|
|Status|Unresolved|


_burnFee = burnFee
_taxFee = taxFee


##### Recommendation

Emit an event for critical parameter changes.


-----

