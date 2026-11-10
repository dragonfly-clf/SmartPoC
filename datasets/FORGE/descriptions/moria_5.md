#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L79,L75,L840 and 8 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L79,L75,L840 and 8 more|

```
mod
addLiquidity
_msgData

```
...


##### Recommendation

Remove unused functions.


-----

