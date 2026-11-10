#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L615, 619, 831, 836

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations.

|Criticality|minor|
|---|---|
|Location|contract.sol#L615, 619, 831, 836|

```
// buy fees
  uint256 public buyDevFee = 2;
  uint256 public buyLiquidityFee = 3;

```
```
function updateBuyFees(uint256 dev, uint256 liquidity) public onlyOwner {
    buyDevFee = dev;
    buyLiquidityFee = liquidity;
    buyTotalFees = dev.add(liquidity);
  }

```

##### Recommendation

Remove buyDevFee, buyLiquidityFee, sellDevFee, sellLiquidityFee from code
segments so the runtime will be more performant.


-----

