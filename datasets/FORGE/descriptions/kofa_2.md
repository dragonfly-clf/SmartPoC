#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L1903,L1855,L1474 and 25 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1903,L1855,L1474 and 25 more|

```
process
getAccountAtIndex
dividendTokenBalanceOf

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

