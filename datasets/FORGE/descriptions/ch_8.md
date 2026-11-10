#### L14 - Uninitialized Variables in Local Scope

**Criticality** minor

**Location** contract.sol#L242,241,297

##### Description

The are variables that are defined in the local scope and are not initialized.

|Criticality|minor|
|---|---|
|Location|contract.sol#L242,241,297|

```
feeAmount
isSell
takeFee

```

##### Recommendation

All the local scoped variables should be initialized.