#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L367,327,337,352,362,274,301

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L367,327,337,352,362,274,301|

```
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```

##### Recommendation

Remove unused functions.