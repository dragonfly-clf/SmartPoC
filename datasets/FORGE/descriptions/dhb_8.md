#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L151,134,138,142,146,114,125,867

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L151,134,138,142,146,114,125,867|

```
addLiquidity
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```

##### Recommendation

Remove unused functions.


-----

