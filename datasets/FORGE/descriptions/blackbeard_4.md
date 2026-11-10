#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L99,106,127,648,654,733

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L99,106,127,648,654,733|

```
getUnpaidEarnings
enable_blacklist
manage_blacklist
transferOwnership
unauthorize
authorize

```

##### Recommendation

Use the external attribute for functions never called from the contract


-----

