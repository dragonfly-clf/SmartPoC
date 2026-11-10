#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L527,L539,L568 and 17 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L527,L539,L568 and 17 more|

```
trySub
tryMul
tryMod

```
...


##### Recommendation

Remove unused functions.


-----

