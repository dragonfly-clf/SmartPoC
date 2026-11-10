#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L128,134,202,206,210,214,222,227,231,236 and 6 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L128,134,202,206,210,214,222,227,231,236 and 6 more|

```
excludeMultipleAccountsFromFees
toggleSwap
setFee
setNewMarketingAddress
setNewDevAddress
rescueForeignTokens
transferFrom
approve
allowance

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

