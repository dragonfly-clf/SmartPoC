#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L320,329,469,488,501

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L320,329,469,488,501|

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

