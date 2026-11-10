#### L13 - Divide before Multiply Operation

**Criticality** Minor / Informative

**Location** Jesus.sol#L569,570,571,575,576,577,578

**Status** Unresolved

#### Description

It is important to be aware of the order of operations when performing arithmetic

calculations. This is especially important when working with large numbers, as the order of

operations can affect the final result of the calculation. Performing divisions before

multiplications may cause loss of prediction.
```
 tokensForLiquidity += fees * sellLiquidityFee / sellTotalFees;
 tokensForMarketing += fees * sellMarketingFee / sellTotalFees;
 tokensForBurn += fees * sellBurnFee / sellTotalFees;
 fees = amount * (buyTotalFees) / (100);
 tokensForLiquidity += fees * buyLiquidityFee / buyTotalFees;
 tokensForMarketing += fees * buyMarketingFee / buyTotalFees;
 tokensForBurn += fees * buyBurnFee / buyTotalFees;

#### Recommendation

```
To avoid this issue, it is recommended to carefully consider the order of operations when

performing arithmetic calculations in Solidity. It's generally a good idea to use parentheses

to specify the order of operations. The basic rule is that the multiplications should be prior

to the divisions.


-----

