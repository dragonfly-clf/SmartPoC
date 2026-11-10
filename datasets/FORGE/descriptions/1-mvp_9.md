#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L118,101,105,109,113,82,93

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L118,101,105,109,113,82,93|

```
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```

##### Recommendation

Remove unused functions.


-----

