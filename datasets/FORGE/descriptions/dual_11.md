#### L15 - Local Scope Variable Shadowing

**Criticality** minor

**Location** contract.sol#L604,644,648,652,656,1079

##### Description

The are variables that are defined in the local scope containing the same name from
an upper scope.

|Criticality|minor|
|---|---|
|Location|contract.sol#L604,644,648,652,656,1079|

```
totalSupply
_owner
_symbol
_name

```

##### Recommendation

The local variables should have different names from the upper scoped variables.