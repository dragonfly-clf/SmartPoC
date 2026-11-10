#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L437,428,238,96,71

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L437,428,238,96,71|

```
toString
toHexString
_msgData

```
...


##### Recommendation

Remove unused functions.


-----

