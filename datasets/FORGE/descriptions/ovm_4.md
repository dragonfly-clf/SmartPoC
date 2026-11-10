#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L175,135,139,143,147,165,169,154,158,123 and 10 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L175,135,139,143,147,165,169,154,158,123 and 10 more|

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

