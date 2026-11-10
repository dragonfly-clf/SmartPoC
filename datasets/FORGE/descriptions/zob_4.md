#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L561,564,567,570,577,581,584,588,593,597 and 5 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L561,564,567,570,577,581,584,588,593,597 and 5 more|

```
F27__CSO_Change__By_Chief_Security_Officer
F26__CEO_Change__By_Chief_Security_Officer
A14__CSO_Address
A13__CEO_Address
reflectionFromToken
decreaseAllowance
increaseAllowance
transferFrom
approve

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

