#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L907,L901,L897 and 3 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L907,L901,L897 and 3 more|

```
_maxWalletSize = _tTotal.mul(maxWallPercent).div(10 ** 2)
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 2)
_marketingFee = fee

```
...


##### Recommendation

Emit an event for critical parameter changes.