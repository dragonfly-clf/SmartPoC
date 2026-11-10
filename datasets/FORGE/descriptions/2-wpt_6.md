#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L85,101,300,51,285,93,107,281,253

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L85,101,300,51,285,93,107,281,253|

```
blackListAddress
burn
allowance
unpause
updateFee
transferOwnership
mint
balanceOf
pause

```

##### Recommendation

Use the external attribute for functions never called from the contract.


-----

