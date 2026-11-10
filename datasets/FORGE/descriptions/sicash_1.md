#### RVO - Ratio Value Overflow

**Criticality** Critical

**Location** contract.sol#L930

**Status** Unresolved

##### Description

The contract could revert the transaction if the
```
_percentageOfLiquidityForMarketing is more than 100.

```
|Criticality|Critical|
|---|---|
|Location|contract.sol#L930|
|Status|Unresolved|

```
uint256 marketingFee     =
newBalance.mul(_percentageOfLiquidityForMarketing).div(100);
uint256 bnbForLiquidity = newBalance.sub(marketingFee);

```

##### Recommendation

The _percentageOfLiquidityForMarketing should not be able to set more than
100.


-----

