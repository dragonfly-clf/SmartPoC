#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L545,553,561,569,581,585

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L545,553,561,569,581,585|

```
minimumTokensBeforeSwap = newLimit
_walletMax = newLimit
_maxTxAmount = maxTxAmount
_liquidityShare = newLiquidityShare
_totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee)
_totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee)

```

##### Recommendation

Emit an event for critical parameter changes.


-----

