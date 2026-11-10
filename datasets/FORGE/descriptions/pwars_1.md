#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L282,291,509,513,520,526,715,723,740,766 and 19 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L282,291,509,513,520,526,715,723,740,766 and 19 more|

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

