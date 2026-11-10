#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L877,L873,L801 and 6 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L877,L873,L801 and 6 more|

```
_maxTxAmount = rSupply.div(1000).mul(maxTXPercentage_base1000)
_maxWalletToken = rSupply.div(1000).mul(maxWallPercent_base1000)
targetLiquidity = _target

```
...


##### Recommendation

Emit an event for critical parameter changes.


-----

