#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L73,77,90,425

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L73,77,90,425|

```
manage_blacklist
transferOwnership
unauthorize
authorize

```

##### Recommendation

Use the external attribute for functions never called from the contract.


-----

