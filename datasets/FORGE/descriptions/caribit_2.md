#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L1928,L1884,L1665 and 26 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1928,L1884,L1665 and 26 more|

```
process
getAccountAtIndex
manualBuyBackAndBurn

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

