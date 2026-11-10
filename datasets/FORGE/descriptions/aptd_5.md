#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L559,567,670,674,678,682,831,837,843,853 and 1 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L559,567,670,674,678,682,831,837,843,853 and 1 more|

```
whitelistPreSale
tradingStatus
updateSwapPercentages
updateSellFees
updateBuyFees
balanceOf
decimals
symbol
name

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

