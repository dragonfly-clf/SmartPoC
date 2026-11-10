#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L37,42,86,90,94,106,111,115,120,126 and 13 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L37,42,86,90,94,106,111,115,120,126 and 13 more|

```
getIsExcludedFromFees
setAutomatedMarketMakerPair
process
getAccountAtIndex
size
getKeyAtIndex
getIndexOfKey
get
withdrawnDividendOf

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

