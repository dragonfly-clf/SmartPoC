#### L14 - Uninitialized Variables in Local Scope

**Criticality** minor

**Location** contract.sol#L1151,770

##### Description

The are variables that are defined in the local scope and are not initialized.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1151,770|

```
claims
i
iterations

```
...


##### Recommendation

All the local scoped variables should be initialized.


-----

