#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L529,458,572,441,484,552,433,1116,1129,465,507,1147

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L529,458,572,441,484,552,433,1116,1129,465,507,1147|


renounceRole
approve
totalSupply
revokeRole
grantRole
name
increaseAllowance
transfer
symbol
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

