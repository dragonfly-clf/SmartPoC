#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L284,293,676,684,701,727,735,746,764,782 and 18 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L284,293,676,684,701,727,735,746,764,782 and 18 more|

```
process
getAccountAtIndex
dividendTokenBalanceOf
withdrawableDividendOf
isExcludedFromFees
updateGasForProcessing
setAutomatedMarketMakerPair
excludeMultipleAccountsFromFees
updateUniswapV2Router

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

