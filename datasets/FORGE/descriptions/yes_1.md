#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L450,464,472,431

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L450,464,472,431|


increaseAllowance
burn
mint
decreaseAllowance


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

