#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L2054,L2002,L1998 and 34 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2054,L2002,L1998 and 34 more|

```
setSwapAndLiquifyEnabled
dividendTokenBalanceOf
withdrawableDividendOf

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

