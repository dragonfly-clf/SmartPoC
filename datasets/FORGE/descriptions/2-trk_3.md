#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L23,599,579,501

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L23,599,579,501|

```
_burn
_beforeTokenTransfer
_afterTokenTransfer
_msgData

```

##### Recommendation

Remove unused functions.