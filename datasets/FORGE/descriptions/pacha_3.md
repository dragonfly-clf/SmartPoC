#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L956,L917,L913 and 23 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L956,L917,L913 and 23 more|

```
setBuyBackEnabled
includeInFee
excludeFromFee

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

