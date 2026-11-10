#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L594,598,602

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L594,598,602|

```
_liquidityFee = liquidityFee
_DevWalletFee = DevWalletFee
_taxFee = taxFee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

