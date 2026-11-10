#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L447,382,395,414,434,318,350

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L447,382,395,414,434,318,350|


sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue


##### Recommendation

Remove unused functions.


-----

