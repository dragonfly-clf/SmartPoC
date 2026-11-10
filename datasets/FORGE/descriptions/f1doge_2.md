#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L161,166,172,548,552,556,560,568,572,577,582,586,599,607,611,61
5,620,677,682,686,694,716,721

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L161,166,172,548,552,556,560,568,572,577,582,586,599,607,611,61 5,620,677,682,686,694,716,721|

```
transferFrom
transfer
changeRouterVersion
getCirculatingSupply
setSwapAndLiquifyByLimitOnly
setSwapAndLiquifyEnabled
setSellDestFee
setBuyDestFee
setMaxDesAmount

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

