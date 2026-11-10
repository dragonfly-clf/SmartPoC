#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L691,699,887,895,912,919,944,957,974,997 and 6 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L691,699,887,895,912,919,944,957,974,997 and 6 more|

```
isExcludedFromFees
setAutomatedMarketMakerPair
excludeMultipleAccountsFromFees
burn
decreaseAllowance
increaseAllowance
transferFrom
approve
allowance

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

