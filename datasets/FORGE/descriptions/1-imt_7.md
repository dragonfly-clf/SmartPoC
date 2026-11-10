#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L644

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L644|


swapTokensAtAmount = newAmount


##### Recommendation

Emit an event for critical parameter changes.


-----

