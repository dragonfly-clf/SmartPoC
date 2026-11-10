#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L600,608,612

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L600,608,612|

```
_liquidityFee = liquidityFee
_Marketing = Marketing
_taxFee = taxFee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

