#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L2104,L2045,L1663 and 22 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2104,L2045,L1663 and 22 more|

```
process
getAccountAtIndex
dividendTokenBalanceOf

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

