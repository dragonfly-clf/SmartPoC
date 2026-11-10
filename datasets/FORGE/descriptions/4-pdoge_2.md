#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L110,116,187,191,195,199,207,212,216,221,240,246,316,322,329,4
03,414,418

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L110,116,187,191,195,199,207,212,216,221,240,246,316,322,329,4 03,414,418|

```
excludeMultipleAccountsFromFees
toggleSwap
setFee
setNewMarketingAddress
setNewDevAddress
rescueForeignTokens
enable_blacklist
manage_blacklist
transferFrom

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

