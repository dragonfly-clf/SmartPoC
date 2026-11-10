#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L657,L652,L630 and 20 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L657,L652,L630 and 20 more|

```
transferFrom
transfer
changeRouterVersion

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

