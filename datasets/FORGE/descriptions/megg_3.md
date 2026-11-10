#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L519,466,476,495,509,411,440,810,849,370,375

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L519,466,476,495,509,411,440,810,849,370,375|

```
sqrt
min
_burnFrom
_burn
sendValue
isContract
functionCallWithValue
functionCall
_functionCallWithValue

```
...


##### Recommendation

Remove unused functions.


-----

