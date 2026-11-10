#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L488,L22

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L488,L22|

```
_burn
_msgData

```

##### Recommendation

Remove unused functions.


-----

