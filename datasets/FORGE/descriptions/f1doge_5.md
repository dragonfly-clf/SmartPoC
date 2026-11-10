#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L126,109,113,117,121,90,101

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L126,109,113,117,121,90,101|

```
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```

##### Recommendation

Remove unused functions.