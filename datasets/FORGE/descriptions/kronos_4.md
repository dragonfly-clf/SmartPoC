#### L06 - Missing Events Access Control

**Criticality** minor

**Location** contract.sol#L1116

##### Description

Detected missing events for critical access control parameters. There are functions
that have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1116|

```
_vault = vault_

```

##### Recommendation

Emit an event for critical parameter changes.


-----

