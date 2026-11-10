#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L66,70,251,255,264,273,277,282,296,301 and 9 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L66,70,251,255,264,273,277,282,296,301 and 9 more|

```
rescueAnyBEP20Tokens
setSellTaxes
setTaxes
isExcludedFromFee
includeInFee
excludeFromFee
reflectionFromToken
isExcludedFromReward
transfer

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

