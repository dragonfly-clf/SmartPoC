#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L788,796

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L788,796|


transferOwnership
renounceOwnership


##### Recommendation

Use the external attribute for functions never called from the contract


-----

