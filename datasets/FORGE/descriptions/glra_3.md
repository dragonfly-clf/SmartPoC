#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L177,185,202,209,216,228,236,247,265,293 and 12 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L177,185,202,209,216,228,236,247,265,293 and 12 more|

```
disableTax
enableTax
removeExclude
disableBlacklist
enableBlacklist
burn
unpause
pause
triggerTax

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

