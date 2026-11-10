#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L211,L221,L246 and 10 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L211,L221,L246 and 10 more|

```
trySub
tryMul
tryMod

```
...


##### Recommendation

Remove unused functions.