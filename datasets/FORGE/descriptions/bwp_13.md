#### L09 - Dead Code Elimination

**Criticality** minor / informative

**Location** contract.sol#L705,614,621,629,643,683,695,660,673,600,103,97,89,93,32,758,77
1,739

**Status** Unresolved

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L705,614,621,629,643,683,695,660,673,600,103,97,89,93,32,758,77 1,739|
|Status|Unresolved|

```
_verifyCallResult
functionCall
functionCallWithValue
functionDelegateCall
functionStaticCall
sendValue
findDownerBound
average
max

```
...


##### Recommendation

Remove unused functions.