#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1671,1652,1735,1678,1683,1691

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1671,1652,1735,1678,1683,1691|


_maxSellTxAmount = maxSellTxAmount * (10 ** 9)
_minBuyTxAmount = minBuyTxAmount * (10 ** 9)
maxWalletToken = maxWalletToken_ * (10 ** 9)
sellCooldownperiod = _seconds
_taxFee = taxFee
numTokensSellToAddToLiquidity = newAmt * (10 ** 9)


##### Recommendation

Emit an event for critical parameter changes.


-----

