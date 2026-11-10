#### L09 - Dead Code Elimination

**Criticality** minor / informative

**Location** contract.sol#L756,304,355,365,766,370,277,340,330

**Status** Unresolved

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L756,304,355,365,766,370,277,340,330|
|Status|Unresolved|


removeAllFee
sendValue
functionCallWithValue
restoreAllFee
_functionCallWithValue
isContract
functionCall


##### Recommendation

Remove unused functions.