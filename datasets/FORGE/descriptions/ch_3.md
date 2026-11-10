#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L76,85,90,197,205,210,214,219

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L76,85,90,197,205,210,214,219|

```
transferFrom
approve
allowance
transfer
totalSupply
transferOwnership
renounceOwnership
owner

```

##### Recommendation

Use the external attribute for functions never called from the contract.


-----

