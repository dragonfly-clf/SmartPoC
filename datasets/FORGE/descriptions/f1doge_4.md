#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L611,615,620,625,633,641,649,661,665

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L611,615,620,625,633,641,649,661,665|

```
_minimumTokensBeforeSwap = newLimit
_walletMax = newLimit
_maxTxAmount = maxTxAmount
_liquidityShare = newLiquidityShare
_totalTaxIfSelling =
_sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee).add(_sellDestroyFee)
_totalTaxIfBuying =
_buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee).add(_buyDestroyFee)
_sellDestroyFee = newSellDestroyFee
_buyDestroyFee = newBuyDestroyFee
_maxDestroyAmount = maxDestroy

```

##### Recommendation

Emit an event for critical parameter changes.


-----

