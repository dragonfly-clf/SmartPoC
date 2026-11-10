#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L158,167,563,571,576,583,602,610,621,639 and 15 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L158,167,563,571,576,583,602,610,621,639 and 15 more|

```
BigSellAmount
copyMapData
getAmountBNB
getBNB
seteddToken
setswapTokensAtAmount
setisSellAddress
setsellBnbAmount
setsellCount

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

