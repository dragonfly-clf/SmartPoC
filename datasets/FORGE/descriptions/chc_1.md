#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L632,L628,L624 and 12 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L632,L628,L624 and 12 more|

```
setSwapFee
setBurnFee
setSwapAddress

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

