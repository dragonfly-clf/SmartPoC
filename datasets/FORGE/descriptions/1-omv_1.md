#### L01 - Public Function could be Declared External

**Criticality** minor / informative

**Location** contract.sol#L316,465,325,484,497

**Status** Unresolved

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L316,465,325,484,497|
|Status|Unresolved|


renounceOwnership
increaseAllowance
transferOwnership
decreaseAllowance
mint


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

