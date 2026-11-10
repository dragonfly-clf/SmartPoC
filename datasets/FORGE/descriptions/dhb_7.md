#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1066,1070,1078,1082,1091,1095,1099,1104,1109,1113,1117,1121,
1125

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1066,1070,1078,1082,1091,1095,1099,1104,1109,1113,1117,1121, 1125|

```
minimumTokensBeforeSwap = _minimumTokensBeforeSwap
marketingDivisor = divisor
_maxTxAmount = maxTxAmount
buyBackSellLimit = buyBackSellSetLimit
_liquidityFee = liquidityFee
_sellTaxFee = sellTaxFee
_buyTaxFee = buyTaxFee
_taxFee = taxFee
_intervalMinutesForSwap = newMinutes * 60

```
...


##### Recommendation

Emit an event for critical parameter changes.


-----

