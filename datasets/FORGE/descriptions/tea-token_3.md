#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L439,448,454,459,467,760,764,768,772,781,786,790,795,801,806,8
11,816,825,842,875,879,897,983

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L439,448,454,459,467,760,764,768,772,781,786,790,795,801,806,8 11,816,825,842,875,879,897,983|


isExcludedFromFee
setSwapAndLiquifyEnabled
includeInFee
excludeFromFee
excludeFromReward
reflectionFromToken
deliver
isExcludedFromReward
decreaseAllowance
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

