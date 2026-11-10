#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L130,113,117,121,125,94,105

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L130,113,117,121,125,94,105|


sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue


##### Recommendation

Remove unused functions.