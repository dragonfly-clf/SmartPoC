#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L503

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L503|

```
checkTxLimit

```

##### Recommendation

Remove unused functions.