#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L18,L34,L27 and 1 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L18,L34,L27 and 1 more|

```
mul
mod
div

```
...


##### Recommendation

Remove unused functions.