#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L318,466,327,485,498,583

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L318,466,327,485,498,583|


burn
mint
decreaseAllowance
transferOwnership
increaseAllowance
renounceOwnership


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

