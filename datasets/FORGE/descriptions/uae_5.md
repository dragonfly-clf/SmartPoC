#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L129,143,169,165,147,154,175,123,139,158,135

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L129,143,169,165,147,154,175,123,139,158,135|


functionCall
functionStaticCall
isContract
_verifyCallResult
functionCallWithValue
functionDelegateCall
sendValue
...


##### Recommendation

Remove unused functions.


-----

