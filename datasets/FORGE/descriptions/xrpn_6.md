#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L705,L700,L695 and 4 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L705,L700,L695 and 4 more|

```
_maxSellTxAmount = _totalSupply / (1000) * (maxSellTXPercentage_base1000)
_maxBuyTxAmount = _totalSupply / (1000) * (maxBuyTXPercentage_base1000)
_maxWalletToken = _totalSupply / (1000) * (maxWallPercent_base1000)

```
...


##### Recommendation

Emit an event for critical parameter changes.