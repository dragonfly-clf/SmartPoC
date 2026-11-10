#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L995,999,1003,1007,1011,1015,1019,1023,1027,1044 and 1 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L995,999,1003,1007,1011,1015,1019,1023,1027,1044 and 1 more|

```
sellFeeIncreaseFactor = _multiplier
swapTokensAtAmount = _swapAmount * (10 ** 18)
maxSellTransactionAmount = _maxTxn * (10 ** 18)
_LpFeeSell = LpFeeSell * (10 ** 18)
_buybackFeeSell = fee * (10 ** 18)
_marketingFeeSell = fee * (10 ** 18)
_LpFeeBuy = LpFeeBuy * (10 ** 18)
_buybackFeeBuy = fee * (10 ** 18)
_marketingFeeBuy = fee * (10 ** 18)

```
...


##### Recommendation

Emit an event for critical parameter changes.


-----

