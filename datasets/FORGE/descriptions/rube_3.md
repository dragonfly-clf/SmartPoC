#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L115,214,229,249,264,189

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L115,214,229,249,264,189|

```
mul
mod
div
_msgData

```

##### Recommendation

Remove unused functions.