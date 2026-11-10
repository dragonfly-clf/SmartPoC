#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L148,131,135,139,143,111,122,1014

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L148,131,135,139,143,111,122,1014|

```
swapETHForTokens
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```

##### Recommendation

Remove unused functions.


-----

