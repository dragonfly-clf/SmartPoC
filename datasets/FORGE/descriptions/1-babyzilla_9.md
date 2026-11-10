#### L14 - Uninitialized Variables in Local Scope

**Criticality** minor

**Location** contract.sol#L1640,1641,1642

##### Description

The are variables that are defined in the local scope and are not initialized.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1640,1641,1642|

```
lastProcessedIndex
claims
iterations

```

##### Recommendation

All the local scoped variables should be initialized.