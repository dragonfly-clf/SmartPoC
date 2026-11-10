#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L321,330,470,489,502

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L321,330,470,489,502|

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

