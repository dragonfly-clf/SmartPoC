#### BLC - Business Logic Concern

**Criticality** critical

**Location** contract.sol#L1165,1178

##### Description

The contract is transferring the liquidity fee to the pair. This is not working as a
liquidity fee since it is not adding the pair tokens.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1165,1178|

```
super._transfer(sender, uniswapV2Pair, _LiquidityFee);

```

The contract takes a liquidity fee from the sale transactions but it does not transfer it
to any recipient. As a result the total supply diverses from the balances.

```
if(sender == uniswapV2Pair && // Swap BNB to Tokens (BUY)
  recipient != owner() &&
  !excludeFee[recipient]){
  if(taxStatus == true) {
    uint256 _MarketingFee = amount.mul(marketingBuyFee).div(100);
    uint256 _LiquidityFee = amount.mul(liquidityBuyFee).div(100);
    uint256 _BurnFee = amount.mul(burnBuyFee).div(100);
    super._transfer(sender, marketingAddress, _MarketingFee);
    super._burn(sender, _BurnFee);
    amount = amount.sub(_MarketingFee.add(_BurnFee).add(_LiquidityFee));
  }
}
super._transfer(sender, recipient, amount);

```

##### Recommendation

The team is advised to carefully check if the implementation follows the expected
business logic.


-----

