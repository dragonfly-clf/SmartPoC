#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L76,80,92,588,596,659,663

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L76,80,92,588,596,659,663|

```
manage_blacklist
enable_blacklist
launchStatus
tradingStatus
transferOwnership
unauthorize
authorize

```

##### Recommendation

Use the external attribute for functions never called from the contract


-----

