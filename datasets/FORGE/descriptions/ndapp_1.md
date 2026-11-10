#### MTS - Manipulate Total Supply

**Criticality** critical

**Location** contract.sol#L730

##### Description

Owner is able to aggressively manipulate total supply. This change will have a direct
impact on the token price and Market Cap. The owner may take advantage of it by
manipulating the rewardYield and rewardYieldDenominator properties. Additionally,
if the rewardYieldDenominator set to zero, the transactions will revert.

|Criticality|critical|
|---|---|
|Location|contract.sol#L730|

```
function _rebase() private {
  if(!inSwap) {
    uint256 circulatingSupply = getCirculatingSupply().add(balanceOf(DEAD));
    int256 supplyDelta =
int256(circulatingSupply.mul(rewardYield).div(rewardYieldDenominator));
    coreRebase(supplyDelta);
  }
}

```

##### Recommendation

The contract owner should carefully manage the adjustment of the circulating
supply (increases or decreases), according to the token’s price fluctuations.


-----

