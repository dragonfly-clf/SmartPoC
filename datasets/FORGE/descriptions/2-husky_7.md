#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L350,360,379,393,439,449,412,422,325,466 and 1 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L350,360,379,393,439,449,412,422,325,466 and 1 more|


_burnFrom
verifyCallResult
sendValue
functionStaticCall
functionDelegateCall
functionCallWithValue
functionCall
...


##### Recommendation

Remove unused functions.


-----

