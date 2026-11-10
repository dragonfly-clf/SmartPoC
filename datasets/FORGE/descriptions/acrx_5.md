#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L245,L229,L256 and 7 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L245,L229,L256 and 7 more|

```
mod
_msgData
sendValue

```
...


##### Recommendation

Remove unused functions.


-----

