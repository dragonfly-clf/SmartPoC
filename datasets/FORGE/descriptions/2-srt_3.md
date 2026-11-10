#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L300,L285,L281 and 6 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L300,L285,L281 and 6 more|

```
mint
updateFee
burn

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

