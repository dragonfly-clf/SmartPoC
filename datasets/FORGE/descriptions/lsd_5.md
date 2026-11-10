#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L244,L228,L868 and 8 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L244,L228,L868 and 8 more|

```
mod
_getTaxFee
_msgData

```
...


##### Recommendation

Remove unused functions.


-----

