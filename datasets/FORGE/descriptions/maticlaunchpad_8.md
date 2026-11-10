#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L362,322,332,347,357,269,296

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L362,322,332,347,357,269,296|

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

