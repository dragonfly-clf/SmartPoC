#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L1158,L1139,L1116 and 29 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1158,L1139,L1116 and 29 more|

```
transferForeignToken
changeRouterVersion
setAutoBuyBackEnabled

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

