#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L144,127,131,135,139,108,119

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L144,127,131,135,139,108,119|

```
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```

##### Recommendation

Remove unused functions.