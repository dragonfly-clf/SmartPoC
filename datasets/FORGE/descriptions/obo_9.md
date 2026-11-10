#### L09 - Dead Code Elimination

**Criticality** minor / informative

**Location** contract.sol#L551,39,45,1109,350,63,1203,60,46,307,1015,52,1131,68,268,38,4
4,330,55,43

**Status** Unresolved

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L551,39,45,1109,350,63,1203,60,46,307,1015,52,1131,68,268,38,4 4,330,55,43|
|Status|Unresolved|


_addFees
sendValue
functionCallWithValue
_isV2Pair
_addLiquidity
functionDelegateCall
_approveDelegate
_swapAndLiquify
_burn
...


##### Recommendation

Remove unused functions.


-----

