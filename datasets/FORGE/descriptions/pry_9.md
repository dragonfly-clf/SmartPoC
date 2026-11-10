#### L13 - Divide before Multiply Operation

**Criticality** Minor / Informative

**Location** contracts/Pry.sol#L1274,1275,1276,1279,1280,1281

**Status** Unresolved

#### Description

It is important to be aware of the order of operations when performing arithmetic

calculations. This is especially important when working with large numbers, as the order of

operations can affect the final result of the calculation. Performing divisions before

multiplications may cause loss of prediction.
```
 fees = (amount * sellTotalFees) / 100
 tokensForLiquidity += (fees * sellLiquidityFee) / sellTotalFees

#### Recommendation

```
To avoid this issue, it is recommended to carefully consider the order of operations when

performing arithmetic calculations in Solidity. It's generally a good idea to use parentheses

to specify the order of operations. The basic rule is that the multiplications should be prior

to the divisions.


-----

