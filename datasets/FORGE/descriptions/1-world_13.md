#### L13 - Divide before Multiply Operation

**Criticality** Minor / Informative

**Location** WorldToken.sol#L790,791,793,819,820,834,835,840,841,846,847,852,853
,857,858,859,864,868,869,870,874,875,876,882,883,884,888,889,890,89
4,895,896,900,901,902,909,910,911,917,918,919,923,924,925

**Status** Unresolved

#### Description

It is important to be aware of the order of operations when performing arithmetic

calculations. This is especially important when working with large numbers, as the order of

operations can affect the final result of the calculation. Performing divisions before

multiplications may cause loss of prediction.
```
 uint256 percent = (myBalance * 10000) / total;
 uint256 amount = (_balances[worldPoolWallet] * percent) / 10000;
 uint256 amountToTeam = amount * 300 / 10000;
 ...

#### Recommendation

```
To avoid this issue, it is recommended to carefully consider the order of operations when

performing arithmetic calculations in Solidity. It's generally a good idea to use parentheses

to specify the order of operations. The basic rule is that the multiplications should be prior

to the divisions.