#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L365,325,335,350,360,272,299

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L365,325,335,350,360,272,299|


sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue


##### Recommendation

Remove unused functions.