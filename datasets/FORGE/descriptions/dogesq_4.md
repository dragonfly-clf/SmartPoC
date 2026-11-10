#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L510,529,538,626,634,643,648,658,662,666,675,680,684,689,696,7
01,706,710,788,1037,1041,1045,1049,1053,1056,1060,1066

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L510,529,538,626,634,643,648,658,662,666,675,680,684,689,696,7 01,706,710,788,1037,1041,1045,1049,1053,1056,1060,1066|


setLiquidityAddress
setMarketingAddress
setBurnPercent
setMarketingFee
setLiquidityFee
setReflectionFee
IncludeFromFee
ExcludedFromFee
_burn
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

