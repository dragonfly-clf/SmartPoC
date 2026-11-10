#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L534,530,526,495,482,628,500,623

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L534,530,526,495,482,628,500,623|


setAddLPAddress
transferOwnership
setAntiBotAmount
owner
renounceOwnership
name
symbol
decimals


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

