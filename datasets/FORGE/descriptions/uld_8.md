#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L291,342,352,357,264,327,317

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L291,342,352,357,264,327,317|


functionCall
isContract
_functionCallWithValue
functionCallWithValue
sendValue


##### Recommendation

Remove unused functions.