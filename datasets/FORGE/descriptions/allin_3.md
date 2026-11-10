#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L77,79,85,673,695,700

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L77,79,85,673,695,700|

```
cooldownEnabled
tradingStatus
getUnpaidEarnings
transferOwnership
unauthorize
authorize

```

##### Recommendation

Use the external attribute for functions never called from the contract.


-----

