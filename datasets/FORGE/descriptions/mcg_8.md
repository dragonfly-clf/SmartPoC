#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L1916,2145

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1916,2145|

```
dividendsFromSell =
address(this).balance.mul(sellAmount).div(totalAmount).mul(MCGRewardsSellFee).di
v(MCGRewardsSellFee.add(operationsFees))
dividendsFromBuy =
address(this).balance.mul(buyAmount).div(totalAmount).mul(MCGRewardsBuyFee).div(
MCGRewardsBuyFee.add(operationsFees))
swapAmountSold = contractTokenBalance.mul(sellAmount).div(totalBuySell)
swapAmountBought = contractTokenBalance.mul(buyAmount).div(totalBuySell)

```

##### Recommendation

The multiplications should be prior to the divisions.


-----

