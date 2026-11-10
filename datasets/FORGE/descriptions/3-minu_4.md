#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L449,458,464,469,477,784,802,867,927,931,935,1016

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L449,458,464,469,477,784,802,867,927,931,935,1016|

```
isExcludedFromFee
setSwapItAndLiquifyEnabled
includeInFee
excludeFromFee
excludeFromReward
getBalanceAbleSell
decimals
unlock
lock

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

