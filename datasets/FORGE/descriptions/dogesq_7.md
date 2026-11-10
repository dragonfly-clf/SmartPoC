#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1045,1049,1053,1056

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1045,1049,1053,1056|


_BurnFee = fee
_marketingFee = fee
_liquidityFee = fee
_taxFee = fee


##### Recommendation

Emit an event for critical parameter changes.


-----

