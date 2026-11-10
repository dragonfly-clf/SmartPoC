#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L774,778,782,790,799,804,810,815,922,945,969,978,1000,1234,12
38,1329,1333

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L774,778,782,790,799,804,810,815,922,945,969,978,1000,1234,12 38,1329,1333|

```
setAutomatedMarketMakerPair
isExcludedFromFees
burnFrom
burn
vault
renounceOwnership
owner
nonces
permit

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

