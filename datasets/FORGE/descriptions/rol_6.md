#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L484,392,402,417,427,466,476,442,452,339 and 10 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L484,392,402,417,427,466,476,442,452,339 and 10 more|

```
trySub
tryMul
tryMod
tryDiv
tryAdd
mod
div
_msgData
sendValue

```
...


##### Recommendation

Remove unused functions.


-----

