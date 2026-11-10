#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L173,L187,L249 and 24 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L173,L187,L249 and 24 more|

```
mul
div
trySub

```
...


##### Recommendation

Remove unused functions.


-----

