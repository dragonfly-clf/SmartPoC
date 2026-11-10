#### ISA - Inaccurate Swap Amount


#### Description


The contract calculates the amount of tokens that have been bought and sold in


preparation for the swap functionality. The contract is using the `liquidityFee` variable


in both expressions, while the `swapSellTokens` should be calculated using the

```
sellLiquidityFee . As a result, the contract will swap an inaccurate amount of tokens.

```

#### Recommendation


The team is advised to use the `sellLiquidityFee` for the calculation of the sold


tokens.


-----

