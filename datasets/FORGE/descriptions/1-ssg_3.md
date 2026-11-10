#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L1478,1491,1510,1530,1590,1608,1554,1573,1423,1447,1625,854,8
40,870,1018,934,1106,909,1081,1004,920,1092,899,1071,1034,950,1122

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1478,1491,1510,1530,1590,1608,1554,1573,1423,1447,1625,854,8 40,870,1018,934,1106,909,1081,1004,920,1092,899,1071,1034,950,1122|

```
values
remove
length
contains
at
_values
_length
_at
verifyCallResult

```
...


##### Recommendation

Remove unused functions.


-----

