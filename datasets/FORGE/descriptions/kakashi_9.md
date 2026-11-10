#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L357,317,327,342,352,264,291

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L357,317,327,342,352,264,291|

```
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```

##### Recommendation

Remove unused functions.