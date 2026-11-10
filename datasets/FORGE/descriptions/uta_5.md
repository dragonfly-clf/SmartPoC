#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L582,617,564

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L582,617,564|

```
_mint
_burnFrom
_burn

```

##### Recommendation

Remove unused functions.


-----

