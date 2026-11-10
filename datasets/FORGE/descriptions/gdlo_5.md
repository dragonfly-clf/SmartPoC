#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L22,L28,L42 and 17 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L22,L28,L42 and 17 more|

```
trySub
tryMul
tryMod

```
...


##### Recommendation

Remove unused functions.


-----

