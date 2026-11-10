#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L187,195,212,219,226,238,246,257,275,303 and 10 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L187,195,212,219,226,238,246,257,275,303 and 10 more|

```
adminEmergency
claim
claimStateUpdate
signerAddressUpdate
mint
unpause
pause
transferOwnership
renounceOwnership

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

