#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L644,L640,L574 and 4 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L644,L640,L574 and 4 more|

```
manage_blacklist
enable_blacklist
cooldownEnabled

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

