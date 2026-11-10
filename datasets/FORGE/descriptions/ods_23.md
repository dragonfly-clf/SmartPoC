#### L13 - Divide before Multiply Operation

**Criticality** Minor / Informative

**Location** Odesis.sol#L1496,1499,1503,1507,1670,1672,1674,1675,1676

**Status** Unresolved

#### Description

It is important to be aware of the order of operations when performing arithmetic

calculations. This is especially important when working with large numbers, as the order of

operations can affect the final result of the calculation. Performing divisions before

multiplications may cause a loss of prediction.
```
 feePortions = address(this).balance.div(_completeFees)
 uint256 botPayout = buyBotFee.add(sellBotFee) * feePortions

#### Recommendation

```
To avoid this issue, it is recommended to carefully consider the order of operations when

performing arithmetic calculations in Solidity. It's generally a good idea to use parentheses

to specify the order of operations. The basic rule is that the multiplications should be prior

to the divisions.


-----

