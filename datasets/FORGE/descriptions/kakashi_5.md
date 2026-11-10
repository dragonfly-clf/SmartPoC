#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L431,440,446,451,459,758,762,766,770,779,784,788,793,799,804,8
09,813,817,826,843,876,880,884,973,1001

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L431,440,446,451,459,758,762,766,770,779,784,788,793,799,804,8 09,813,817,826,843,876,880,884,973,1001|

```
sendMarketToken
isExcludedFromFee
setSwapAndLiquifyEnabled
includeInFee
excludeFromFee
excludeFromReward
reflectionFromToken
deliver
totalFees

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

