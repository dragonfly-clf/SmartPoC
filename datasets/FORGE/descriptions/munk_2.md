#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L148,155,176,714

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L148,155,176,714|

```
launch
transferOwnership
unauthorize
authorize

```

##### Recommendation

Use the external attribute for functions never called from the contract.

