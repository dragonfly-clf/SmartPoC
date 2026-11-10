#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L1595

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations.

The “swapTokensForEth()” is called four times during the swap & liquify process.
The repetitive call produced a lot of gas fees.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1595|

```
uint256 marketingTokens = contractTokenBalance
.mul(marketingFee)
.div(totalFees);
swapAndSendDividendsToMarketing(marketingTokens);
uint256 buyBackTokens = contractTokenBalance
.mul(buyBackFee)
.div(totalFees);
swapAndSendDividendsToBuyBackAddress(buyBackTokens);
uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(
  totalFees
);
swapAndLiquify(swapTokens);
uint256 sellTokens = balanceOf(address(this));
swapAndSendDividends(sellTokens);

```

##### Recommendation

There could be one call to the “swapTokensForEth()” function that swaps the
accumulated amount. Then the total amount could be splitted proportionally.


-----

