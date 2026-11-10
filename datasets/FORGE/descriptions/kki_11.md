#### L09 - Dead Code Elimination

**Criticality** minor / informative

**Location** contract.sol#L462,526,318,695,603,652,2257,350,633,614,546,559,670,433,507,
494

**Status** Unresolved

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L462,526,318,695,603,652,2257,350,633,614,546,559,670,433,507, 494|
|Status|Unresolved|


sendValue
functionCallWithValue
abs
_callOptionalReturn
safeTransfer
safeIncreaseAllowance
_dtransfer
get
safeApprove
...


##### Recommendation

Remove unused functions.


-----

