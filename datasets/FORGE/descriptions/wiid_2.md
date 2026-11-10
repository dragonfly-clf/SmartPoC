#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L213,219,227,235,491,495,499,503,512,517,521,526,532,537,542,54
6,550,559,576,609,613,629,633,638,742,884,900

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L213,219,227,235,491,495,499,503,512,517,521,526,532,537,542,54 6,550,559,576,609,613,629,633,638,742,884,900|

```
withdrawEth
rescuetokens
isExcludedFromFee
setSwapAndLiquifyEnabled
setDevWalletAddress
setMaxTxPercent
includeInFee
excludeFromFee
excludeFromReward

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

