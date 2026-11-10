#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L553,588,113,212,227,247,262,187,158

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L553,588,113,212,227,247,262,187,158|

```
sub
mul
mod
div
_msgData
_burnFrom
_burn

```

##### Recommendation

Remove unused functions.