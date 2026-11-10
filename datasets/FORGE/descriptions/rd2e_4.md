#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L87,116,176,186,149,159,62,386,410,401,370

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L87,116,176,186,149,159,62,386,410,401,370|

```
safeTransferFrom
safeIncreaseAllowance
safeDecreaseAllowance
safeApprove
sendValue
functionStaticCall
functionDelegateCall
functionCallWithValue
functionCall

```
...


##### Recommendation

Remove unused functions.