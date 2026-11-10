#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L159,280,287

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L159,280,287|

```
toInt256Safe
toUint256Safe
_setupDecimals

```

##### Recommendation

Remove unused functions.


-----

