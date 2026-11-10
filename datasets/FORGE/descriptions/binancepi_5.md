#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L569,577,585,593,605,609

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L569,577,585,593,605,609|

```
minimumTokensBeforeSwap = newLimit
_walletMax = newLimit
_maxTxAmount = maxTxAmount
_liquidityShare = newLiquidityShare
_totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellLPFee)
_totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyLPFee)

```

##### Recommendation

Emit an event for critical parameter changes.


-----

