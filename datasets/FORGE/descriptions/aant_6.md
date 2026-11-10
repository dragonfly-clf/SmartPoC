#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L31,690,521,594,584,599,533,551,556,544 and 3 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L31,690,521,594,584,599,533,551,556,544 and 3 more|

```
mul
div
trySub
tryMul
tryMod
tryDiv
tryAdd
mod
_setupDecimals

```
...


##### Recommendation

Remove unused functions.


-----

