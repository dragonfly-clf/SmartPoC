#### L06 - Missing Events Access Control

**Criticality** minor / informative

**Location** contract.sol#L423,419

**Status** Unresolved

##### Description

Detected missing events for critical access control parameters. There are functions
that have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L423,419|
|Status|Unresolved|


buybackAddress = addr
fundAddress = addr


##### Recommendation

Emit an event for critical parameter changes.


-----

