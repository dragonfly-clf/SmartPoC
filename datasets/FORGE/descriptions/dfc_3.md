#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L301,309,502,510,527,534,553,576,598,621,641,867,871

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L301,309,502,510,527,534,553,576,598,621,641,867,871|

```
isExcludedFromFee
isBlacklisted
decreaseAllowance
increaseAllowance
transferFrom
approve
transfer
totalSupply
decimals

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

