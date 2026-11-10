#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L318,327,467,486,499

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L318,327,467,486,499|

```
mint
decreaseAllowance
increaseAllowance
transferOwnership
renounceOwnership

```

##### Recommendation

Use the external attribute for functions never called from the contract.


-----

