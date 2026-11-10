#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L326,799,804,832,837

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L326,799,804,832,837|

```
maxWalletLimit = amount * 10 ** decimals()
maxBuyLimit = maxBuy * 10 ** decimals()
swapTokensAtAmount = amount * 10 ** _decimals
coolDownTime = time * 1
deadline = _deadline

```

##### Recommendation

Emit an event for critical parameter changes.


-----

