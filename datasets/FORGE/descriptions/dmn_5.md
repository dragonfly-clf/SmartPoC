#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L20,L540,L371 and 8 more

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L20,L540,L371 and 8 more|

```
_msgData
verifyCallResult
isContract

```
...


##### Recommendation

Remove unused functions.


-----

