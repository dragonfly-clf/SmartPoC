#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L1391,1307,194,1005

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1391,1307,194,1005|

```
abs
get
_withdrawDividendOfUser
_transfer

```

##### Recommendation

Remove unused functions.


-----

