#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L193,198,204,208,212,219,568,572,576,580,589,594,598,603,609,6
14,619,623,627,631,635,645,662,1018,1022,1026,1074,1087,1138,1143,1166,11
85

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L193,198,204,208,212,219,568,572,576,580,589,594,598,603,609,6 14,619,623,627,631,635,645,662,1018,1022,1026,1074,1087,1138,1143,1166,11 85|

```
transferForeignToken
changeRouterVersion
setAutoBuyBackEnabled
setBuyBackEnabled
GetSwapMinutes
GetBuyBackTimeInterval
includeInFee
excludeFromFee
isExcludedFromFee

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

