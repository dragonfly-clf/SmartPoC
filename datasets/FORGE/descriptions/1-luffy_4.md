#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L352,362,381,395,441,451,414,424,303,327 and 2 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L352,362,381,395,441,451,414,424,303,327 and 2 more|


_burnFrom
verifyCallResult
sendValue
isContract
functionStaticCall
functionDelegateCall
functionCallWithValue
functionCall
...


##### Recommendation

Remove unused functions.


-----

