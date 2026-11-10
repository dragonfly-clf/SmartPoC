#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L800,808,893,900,907,914,921

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L800,808,893,900,907,914,921|


balanceOf
totalSupply
symbol
decimals
name
transferOwnership
renounceOwnership


##### Recommendation

Use the external attribute for functions never called from the contract


-----

