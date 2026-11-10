#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L157,530,58,580,131,180,127,143,175,63,123,588,135,152,148

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L157,530,58,580,131,180,127,143,175,63,123,588,135,152,148|


allowance
approve
totalSupply
setPercentWallet
name
transferOwnership
increaseAllowance
transfer
symbol
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

