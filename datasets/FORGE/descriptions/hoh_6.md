#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L130,111,116,121,125,92,102

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L130,111,116,121,125,92,102|

```
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```

##### Recommendation

Remove unused functions.