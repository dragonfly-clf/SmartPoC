#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L301,L313,L342 and 11 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L301,L313,L342 and 11 more|

```
mul
div
abs

```
...


##### Recommendation

Remove unused functions.