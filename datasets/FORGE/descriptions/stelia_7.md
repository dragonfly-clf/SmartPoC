#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L355,315,325,340,350,262,289

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L355,315,325,340,350,262,289|


sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue


##### Recommendation

Remove unused functions.