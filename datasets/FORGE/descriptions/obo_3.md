#### L01 - Public Function could be Declared External

**Criticality** minor / informative

**Location** contract.sol#L129,811,96,100,824,114,108,105

**Status** Unresolved

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L129,811,96,100,824,114,108,105|
|Status|Unresolved|


manager
increaseAllowance
renounceOwnership
transferOwnership
decreaseAllowance
unlock
lock
getUnlockTime


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

