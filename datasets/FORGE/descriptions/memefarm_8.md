#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L276,370,418,358,346,365,250,271,280,109,350,246,242,262,422,2
93,341,266

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L276,370,418,358,346,365,250,271,280,109,350,246,242,262,422,2 93,341,266|


increaseAllowance
setSwapAndLiquifyEnabled
setlsExcIudeFromFee
qwidji
allowance
name
symbol
getCirculatingSupply
transferOwnership
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

