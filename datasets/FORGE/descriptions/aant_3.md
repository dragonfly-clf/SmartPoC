#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L251,255,262,268,323,328,430,434,438,450 and 30 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L251,255,262,268,323,328,430,434,438,450 and 30 more|

```
process
getAccountAtIndex
distributeBUSDDividends
burnRemainingToken
withdrawRemainingBEP20Token
withdrawRemainingToken
updateETHRewardsFee
updateLiquidityFee
updateMarketingFee

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

