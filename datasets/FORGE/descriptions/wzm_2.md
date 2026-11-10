#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L67,105,133,142,161,176,189,221,229

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L67,105,133,142,161,176,189,221,229|

```
freezeAccount
mintToken
burnFrom
burn
approveAndCall
transferFrom
transfer
release
transferOwnership

```

##### Recommendation

Use the external attribute for functions never called from the contract


-----

