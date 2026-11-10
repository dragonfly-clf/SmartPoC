#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L553,588

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L553,588|

```
_burnFrom
_burn

```

##### Recommendation

Remove unused functions.