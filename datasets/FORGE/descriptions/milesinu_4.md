#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L784,918,827,818,926,442,780,798,813,793,1027,451,457,772,831,
857,840,776,823,470,895,807,802,891,909,462

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L784,918,827,818,926,442,780,798,813,793,1027,451,457,772,831, 857,840,776,823,470,895,807,802,891,909,462|


lock
setDevAddress
excludeFromFee
approve
transferFrom
includeInFee
unlock
isExcludedFromReward
symbol
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

