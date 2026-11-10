#### L09 - Dead Code Elimination

**Criticality** minor / informative

**Location** contract.sol#L95,112,1012,116,121,84,108,104

**Status** Unresolved

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L95,112,1012,116,121,84,108,104|
|Status|Unresolved|

```
sendValue
functionCallWithValue
swapETHForTokens
_functionCallWithValue
isContract
functionCall

```

##### Recommendation

Remove unused functions.


-----

