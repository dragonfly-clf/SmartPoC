#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L685,691,696,701

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L685,691,696,701|


_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 3)
_sellAdvestisementFee = sellAdvestisementFee
_buyBurnFee = buyBurnFee
_buyTaxFee = buyTaxFee


##### Recommendation

Emit an event for critical parameter changes.


-----

