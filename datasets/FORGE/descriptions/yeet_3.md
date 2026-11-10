#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L55,59,191,194,197,201,210,215,219,224 and 10 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L55,59,191,194,197,201,210,215,219,224 and 10 more|

```
rescueAnyERC20Tokens
isBot
setTaxes
isExcludedFromFee
includeInFee
excludeFromFee
reflectionFromToken
isExcludedFromReward
decreaseAllowance

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

