#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L391,94,384,314,262,291,380,320,306,301,268,686,98,286,375,273
,324,282,265,371

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L391,94,384,314,262,291,380,320,306,301,268,686,98,286,375,273,324,282,265,371|

```
excludeFromFee
symbol
allowance
reflectionFromToken
totalSupply
includeInFee
approve
transferOwnership
rescueAnyBEP20Tokens

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

