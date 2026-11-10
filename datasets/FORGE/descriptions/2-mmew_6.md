#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L186,123,127,135,143,171 and 8 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L186,123,127,135,143,171 and 8 more|

```
mod
_msgData
sendValue

```
...


##### Recommendation

Remove unused functions.


-----

