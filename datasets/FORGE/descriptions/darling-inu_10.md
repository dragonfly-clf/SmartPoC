#### L14 - Uninitialized Variables in Local Scope

**Criticality** minor

**Location** contract.sol#L656,658,638,640

##### Description

The are variables that are defined in the local scope and are not initialized.

|Criticality|minor|
|---|---|
|Location|contract.sol#L656,658,638,640|

```
i
gasUsed

```

##### Recommendation

All the local scoped variables should be initialized.