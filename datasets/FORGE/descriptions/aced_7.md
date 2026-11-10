#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L299,175,1436

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L299,175,1436|

```
transferToWallet
_setupDecimals
_transfer

```

##### Recommendation

Remove unused functions.


-----

