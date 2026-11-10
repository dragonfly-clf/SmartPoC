#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L36,41,85,89,93,105,110,114,119,125,130,462,467,511,534,539,544,
700,704,708,727

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L36,41,85,89,93,105,110,114,119,125,130,462,467,511,534,539,544, 700,704,708,727|

```
buyBox
resetFeeTotal
migrateBNB
transferTokens
setAutomatedMarketMakerPair
excludeFromMaxTokenPerWallet
excludeFromMaxTxAmount
setPoolShare
setSwapEnable

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

