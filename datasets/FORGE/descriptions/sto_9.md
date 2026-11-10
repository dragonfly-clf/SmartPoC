#### L15 - Local Scope Variable Shadowing

**Criticality** minor

**Location** contract.sol#L544,548

##### Description

The are variables that are defined in the local scope containing the same name from
an upper scope.

|Criticality|minor|
|---|---|
|Location|contract.sol#L544,548|

```
_burn

```

##### Recommendation

The local variables should have different names from the upper scoped variables.