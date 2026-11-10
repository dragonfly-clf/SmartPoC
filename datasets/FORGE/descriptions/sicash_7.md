#### L09 - Dead Code Elimination

**Criticality** minor / informative

**Location** contract.sol#L270,283,276

**Status** Unresolved

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L270,283,276|
|Status|Unresolved|

```
abs
toInt256Safe
toUint256Safe

```

##### Recommendation

Remove unused functions.