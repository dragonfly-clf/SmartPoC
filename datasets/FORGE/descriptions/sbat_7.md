#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L499,407,417,432,442,481,491,457,467,354,381

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L499,407,417,432,442,481,491,457,467,354,381|

```
sendValue
isContract
functionStaticCall
functionDelegateCall
functionCallWithValue
functionCall
_verifyCallResult

```
...


##### Recommendation

Remove unused functions.