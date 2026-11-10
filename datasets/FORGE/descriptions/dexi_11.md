#### L09 - Dead Code Elimination

**Criticality** minor / informative

**Location** contract.sol#L186,190,252,268,165,228,182,296,292,232,204,272,216,281,302,2
36,240,246,264,285,136,178,260

**Status** Unresolved

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L186,190,252,268,165,228,182,296,292,232,204,272,216,281,302,2 36,240,246,264,285,136,178,260|
|Status|Unresolved|

```
length
at
sendValue
functionCallWithValue
_at
remove
contains
functionDelegateCall
functionStaticCall

```
...


##### Recommendation

Remove unused functions.


-----

