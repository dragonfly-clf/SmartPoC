#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L599,L611,L640 and 4 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L599,L611,L640 and 4 more|

```
mul
div
abs

```
...


##### Recommendation

Remove unused functions.


-----

