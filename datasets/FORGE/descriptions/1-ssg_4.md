#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L2382,2396,2499

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2382,2396,2499|

```
tokensOut = _jackpotTokens.mul(jackpotCashout).div(MAX_PCT)
cashedOut = _pendingJackpotBalance.mul(jackpotCashout).div(MAX_PCT)
tokens =
_jackpotTokens.mul(jackpotCashout).div(MAX_PCT).mul(MAX_PCT.sub(jackpotBuyerShar
e)).div(MAX_PCT)
bnb =
_pendingJackpotBalance.mul(jackpotCashout).div(MAX_PCT).mul(MAX_PCT.sub(jackpotB
uyerShare)).div(MAX_PCT)
tokens =
_jackpotTokens.mul(jackpotCashout).div(MAX_PCT).mul(jackpotBuyerShare).div(MAX_P
CT)
bnb =
_pendingJackpotBalance.mul(jackpotCashout).div(MAX_PCT).mul(jackpotBuyerShare).d
iv(MAX_PCT)

```

##### Recommendation

The multiplications should be prior to the divisions.