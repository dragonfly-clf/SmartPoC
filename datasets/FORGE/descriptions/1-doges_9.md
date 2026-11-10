#### L14 - Uninitialized Variables in Local Scope

**Criticality** minor

**Location** contract.sol#L639,637,657,655

##### Description

The are variables that are defined in the local scope and are not initialized.

|Criticality|minor|
|---|---|
|Location|contract.sol#L639,637,657,655|

```
gasUsed
i

```

##### Recommendation

All the local scoped variables should be initialized.