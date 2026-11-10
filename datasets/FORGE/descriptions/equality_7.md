#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L131,114,118,122,126,95,106

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L131,114,118,122,126,95,106|

```
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```

##### Recommendation

Remove unused functions.