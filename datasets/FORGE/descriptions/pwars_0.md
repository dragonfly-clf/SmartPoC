#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L1553

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations.

The process of swapping tokens for BNB is taking place three times during the
liquidation feature. The process of swapping tokens for BNB is producing gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1553|

```
uint256 feeTokens =
contractTokenBalance.mul(marketingFee.add(buybackFee).add(charityFee)).div(total
Fees);
swapAndSendToFee(feeTokens);
uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
swapAndLiquify(swapTokens);
uint256 sellTokens = balanceOf(address(this));
swapAndSendDividends(sellTokens);

```

##### Recommendation

The process of swapping tokens for BNB could be happened once for the total
amount of tokens. Then, the swapped BNB could be distributed according to the
requirements.


-----

