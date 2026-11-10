#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L150,119,122,125,128,142,145,134,137,109,114,472

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L150,119,122,125,128,142,145,134,137,109,114,472|

```
_beforeTokenTransfer
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


-----

