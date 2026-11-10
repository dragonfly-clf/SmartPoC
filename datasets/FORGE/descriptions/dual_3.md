#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L64,68,249,253,257,269,274,278,283,293,298,609,622,644,652,768
,817,861,920,1134,1138,1154,1170,1196,1216,1220,1277,1281,1285,1289,1331,
1467

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L64,68,249,253,257,269,274,278,283,293,298,609,622,644,652,768,817,861,920,1134,1138,1154,1170,1196,1216,1220,1277,1281,1285,1289,1331, 1467|

```
getCirculatingSupply
swapManual
isExcludedFromDividends
dividendTokenBalanceOf
withdrawableDividendOf
isExcludedFromFees
setIsSellLimitExempt
setSwapTokensAtAmount
updateGasForProcessing

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

