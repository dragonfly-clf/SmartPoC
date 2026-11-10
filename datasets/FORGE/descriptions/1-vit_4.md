#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L165,170,176,554,558,562,566,574,578,583 and 14 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L165,170,176,554,558,562,566,574,578,583 and 14 more|


transferFrom
transfer
changeRouterVersion
getCirculatingSupply
setSwapAndLiquifyByLimitOnly
setSwapAndLiquifyEnabled
multipleBotlistAddress
setSellDestFee
setBuyDestFee
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

