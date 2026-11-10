#### ZD - Zero Division

**Criticality** critical

**Location** contract.sol#L573

Resolved
**Status**

##### Description

The contract is using variables that may be set to zero as denominators. As a result,
the transactions will revert.

|Criticality|critical|
|---|---|
|Location|contract.sol#L573|
|Status|Resolved|

```
function swapAndLiquify(uint256 contractBalance, Taxes memory temp) private
lockTheSwap{
    uint256 denominator = (temp.liquidity + temp.marketing + temp.dev +
temp.buyback) * 2;
    uint256 tokensToAddLiquidityWith = contractBalance * temp.liquidity /
denominator;
    uint256 toSwap = contractBalance - tokensToAddLiquidityWith;
    uint256 initialBalance = address(this).balance;
    swapTokensForBNB(toSwap);

```

##### Recommendation

The contract should prevent those variables to be set to zero or should not allow to
execute the corresponding statements.

##### Updated 03 August 2022

The team has renounced ownership, since the tax contains non-zero values, the
denominator will never be able to produce a zero division issue .


-----

-----

