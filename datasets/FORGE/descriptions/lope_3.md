#### L01 - Public Function could be Declared External

**Criticality** minor / informative

**Location** contract.sol#L759,590,1086,696,806,679,722,787,598,671,1135,703,1118,741,7
30

**Status** Unresolved

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L759,590,1086,696,806,679,722,787,598,671,1135,703,1118,741,7 30|
|Status|Unresolved|


transferFrom
renounceOwnership
excludeMultipleAccountsFromFees
decimals
decreaseAllowance
symbol
transfer
increaseAllowance
transferOwnership
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

