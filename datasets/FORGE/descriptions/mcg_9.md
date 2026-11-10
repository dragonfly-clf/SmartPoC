#### L14 - Uninitialized Variables in Local Scope

**Criticality** minor

**Location** contract.sol#L2536,2599,2027,2025,2026

##### Description

The are variables that are defined in the local scope and are not initialized.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2536,2599,2027,2025,2026|

```
claims
iterations
lastProcessedIndex
success

```

##### Recommendation

All the local scoped variables should be initialized.


-----

