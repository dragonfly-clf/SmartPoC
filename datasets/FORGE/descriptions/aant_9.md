#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L882,886,890,894,1263,1268,1273

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L882,886,890,894,1263,1268,1273|

```
liquidityFee = newFee
marketingFee = newFee
swapTokensAtAmount = amountOfTokens
maxSellTransactionAmount = maxSell * (10 ** 18)
maxBuyTranscationAmount = maxBuy * (10 ** 18)
_maxWalletToken = maxWallet * (10 ** 18)

```

##### Recommendation

Emit an event for critical parameter changes.


-----

