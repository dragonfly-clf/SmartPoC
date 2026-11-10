#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L158,L187,L262 and 6 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L158,L187,L262 and 6 more|

```
sub
mul
mod

```
...


##### Recommendation

Remove unused functions.