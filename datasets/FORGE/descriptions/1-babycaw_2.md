#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L190,195,201,205,209,216,552,556,560,564,573,578,582,587,593,59
8,603,607,611,615,619,626,643,932,937,941,995,1028

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L190,195,201,205,209,216,552,556,560,564,573,578,582,587,593,59 8,603,607,611,615,619,626,643,932,937,941,995,1028|

```
manualBurn
setSwapAndLiquifyEnabled
includeInFee
excludeFromFee
isExcludedFromFee
excludeFromReward
reflectionFromToken
manage_blacklist
enable_blacklist

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

