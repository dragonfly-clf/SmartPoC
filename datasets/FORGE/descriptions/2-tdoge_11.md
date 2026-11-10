#### L15 - Local Scope Variable Shadowing

**Criticality** minor / informative

**Location** contract.sol#L1459,1519,1538,1986,1552,1460,1526

**Status** Unresolved

##### Description

The are variables that are defined in the local scope containing the same name from
an upper scope.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1459,1519,1538,1986,1552,1460,1526|
|Status|Unresolved|


_name
_owner
totalSupply
_symbol


##### Recommendation

The local variables should have different names from the upper scoped variables.