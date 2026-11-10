#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L760,768,953,961,978,1004 and 19 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L760,768,953,961,978,1004 and 19 more|

```
process
getAccountAtIndex
dividendTokenBalanceOf

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

