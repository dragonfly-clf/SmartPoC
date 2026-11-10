#### L15 - Local Scope Variable Shadowing

**Criticality** minor

**Location** contract.sol#L1056,1104,1111,1118,1128

##### Description

The are variables that are defined in the local scope containing the same name from
an upper scope.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1056,1104,1111,1118,1128|

```
_owner
_symbol
_name

```

##### Recommendation

The local variables should have different names from the upper scoped variables.