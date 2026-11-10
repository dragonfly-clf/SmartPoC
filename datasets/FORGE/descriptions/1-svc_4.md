#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L177,185,202,209,216,228,236,247,265,293,312,518,526,1016,1023,
1031,1039,1046,1054,1070,1108,1116

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L177,185,202,209,216,228,236,247,265,293,312,518,526,1016,1023, 1031,1039,1046,1054,1070,1108,1116|

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

Use the external attribute for functions never called from the contract.


-----

