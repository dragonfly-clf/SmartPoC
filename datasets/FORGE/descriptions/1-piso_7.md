#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L246,59,279,358,716,287,274,354,704,264,297,63,293,363,238,259
,255,349,235,345

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L246,59,279,358,716,287,274,354,704,264,297,63,293,363,238,259,255,349,235,345|


excludeFromFee
name
includeInFee
allowance
approve
symbol
setSellTaxes
isExcludedFromReward
transferOwnership
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

