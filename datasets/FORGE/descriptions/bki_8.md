#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L951,1014

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L951,1014|

```
ecosystemFee = amount.mul(_SellecosystemFee).div(10 ** (_feeDecimal + 2))
rewardFee = amount.mul(_SellrewardFee).div(10 ** (_feeDecimal + 2))
liquidityFee = amount.mul(_SelllLiquidityFee).div(10 ** (_feeDecimal + 2))
marketingFee = amount.mul(_SellmarketingFee).div(10 ** (_feeDecimal + 2))
taxFee = amount.mul(_SelltaxFee).div(10 ** (_feeDecimal + 2))
ecosystemFee = amount.mul(_ecosystemFee).div(10 ** (_feeDecimal + 2))
rewardFee = amount.mul(_rewardFee).div(10 ** (_feeDecimal + 2))
liquidityFee = amount.mul(_liquidityFee).div(10 ** (_feeDecimal + 2))
marketingFee = amount.mul(_marketingFee).div(10 ** (_feeDecimal + 2))

```
...


##### Recommendation

The multiplications should be prior to the divisions.