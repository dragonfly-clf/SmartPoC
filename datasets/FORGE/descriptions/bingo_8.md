#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L550,557,564,571,583,587

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L550,557,564,571,583,587|


minimumTokensBeforeSwap = newLimit
_walletMax = newLimit
_maxTxAmount = maxTxAmount
_liquidityShare = newLiquidityShare
_totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee)
_totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee)


##### Recommendation

Emit an event for critical parameter changes.


-----

