#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L179,187,211,218,230,253,275,298,318,732,747,799,1149,1167,163
1,1635,1737,1741,1755

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L179,187,211,218,230,253,275,298,318,732,747,799,1149,1167,163 1,1635,1737,1741,1755|

```
setAccount
unpause
pause
setTokensOwner
getTokensOwner
renounceRole
revokeRole
renounceOwnership
burnFrom

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

