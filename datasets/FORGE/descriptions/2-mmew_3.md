#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L244,252,590,598,613,793 and 1 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L244,252,590,598,613,793 and 1 more|

```
reflect
reflectionFromToken
setRouterAddress

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

