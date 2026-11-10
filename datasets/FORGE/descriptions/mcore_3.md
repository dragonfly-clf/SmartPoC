#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L1177,L1170,L1166 and 39 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1177,L1170,L1166 and 39 more|

```
setDailySellLimit
setBuyLimit
withdraw

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

