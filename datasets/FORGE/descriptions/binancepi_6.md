#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L127,110,114,118,122,91,102

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L127,110,114,118,122,91,102|

```
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```

##### Recommendation

Remove unused functions.