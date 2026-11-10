#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1480,1514,1518,1526,2508,1561

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1480,1514,1518,1526,2508,1561|


minimumTokenBalanceForDividends = _minimumTokenBalanceForDividends
gasForProcessing = newValue
_maxWalletAmount = _tTotal.mul(maxWalletPercent).div(10 ** 4)
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 4)
buyBackUpperLimit = buyBackLimit * 10 ** uint256(_decimals)
_taxFee = taxFee


##### Recommendation

Emit an event for critical parameter changes.


-----

