#### L14 - Uninitialized Variables in Local Scope

**Criticality** minor

**Location** contract.sol#L307,404,217

##### Description

The are variables that are defined in the local scope and are not initialized.

|Criticality|minor|
|---|---|
|Location|contract.sol#L307,404,217|

```
bytes4Array_
addressArray

```

##### Recommendation

All the local scoped variables should be initialized.