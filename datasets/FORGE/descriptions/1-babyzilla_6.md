#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L242,1172,899,548,510,568,382,418,428,403 and 4 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L242,1172,899,548,510,568,382,418,428,403 and 4 more|

```
mul
div
abs
trySub
tryMul
tryMod
tryDiv
tryAdd
mod

```
...


##### Recommendation

Remove unused functions.


-----

