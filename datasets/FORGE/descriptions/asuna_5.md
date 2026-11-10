#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L682,688,692,697

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L682,688,692,697|

```
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 3)
_sellAdvestisementFee = sellAdvestisementFee
_burnFee = fee
_buyTaxFee = buyTaxFee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

