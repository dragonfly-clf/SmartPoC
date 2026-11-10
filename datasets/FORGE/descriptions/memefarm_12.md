#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L329,313,305,418,297

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L329,313,305,418,297|


_totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee)
_maxTxAmount = a
_totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee)
_liquidityShare = newLiquidityShare
minimumTokensBeforeSwap = newLimit


##### Recommendation

Emit an event for critical parameter changes.


-----

