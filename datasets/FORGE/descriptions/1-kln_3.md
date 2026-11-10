#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L400,23,657,736,768,819,853

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L400,23,657,736,768,819,853|

```
toTypedDataHash
recover
_throwError
_msgData
_burn

```

##### Recommendation

Remove unused functions.