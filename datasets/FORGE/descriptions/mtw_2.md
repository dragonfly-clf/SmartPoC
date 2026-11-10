#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L1230,L1195,L1191 and 21 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1230,L1195,L1191 and 21 more|

```
setRouterAddress
includeInFee
excludeFromFee

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

