#### MAL - Misused Algorithmic Logic

**Criticality** minor

**Location** contract.sol#L1231

##### Description

The contract transfers tokens to the usiswapV2pair. Usually the uniswapV2pair is
used for inserting liquidity. The tokens that are accumulated in the pair are useless.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1231|

```
super._transfer(sender, uniswapV2Pair, _LiquidityFee);

```

##### Recommendation

The contract should add liquidity to the pair instead of using tokens.


-----

