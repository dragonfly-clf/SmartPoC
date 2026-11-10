#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L429,438,444,449,457,551,555,559,563,567,571,576,581,585,590,59
6,601,606,610,616,667,672,678,808,820,824,828,832

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L429,438,444,449,457,551,555,559,563,567,571,576,581,585,590,59 6,601,606,610,616,667,672,678,808,820,824,828,832|

```
setAntibotModeWhitelist
setAirdropContract
turnOnAntibotMode
turnOffAntibotMode
isExcludedFromFee
includeInFee
manageAmmPairs
excludeFromFee
reflectionFromToken

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

