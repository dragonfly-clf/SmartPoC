#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L119,102,106,110,114,83,94

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L119,102,106,110,114,83,94|

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

