#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L1077,995,1699,1085,1048,497,1338,987,991,983,1013,1644,1031,
506,1004,515,1022,1640,1081,528,1097,1125,520,1061

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1077,995,1699,1085,1048,497,1338,987,991,983,1013,1644,1031, 506,1004,515,1022,1640,1081,528,1097,1125,520,1061|


decreaseAllowance
lock
excludeFromReward
reflectionFromToken
unlock
totalFees
excludeFromFee
approve
geUnlockTime
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

