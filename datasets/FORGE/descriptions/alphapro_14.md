#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L843,1154,703

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L843,1154,703|

```
_gonBalances[autofirePit] =
_gonBalances[autofirePit].add(gonAmount.div(feeDenominator).mul(autofirePitFee
))
feeAmount = gonAmount.div(feeDenominator).mul(_totalFee)
times = deltaTime.div(1800)
_gonBalances[autoLiquidityReceiver] =
_gonBalances[autoLiquidityReceiver].add(gonAmount.div(feeDenominator).mul(liqu
idityFee))
liquidityBalance = _gonBalances[pair].div(_gonsPerFragment)
_gonBalances[address(this)] =
_gonBalances[address(this)].add(gonAmount.div(feeDenominator).mul(_treasuryFee
.add(safuDividendFee)))

```

##### Recommendation

The multiplications should be prior to the divisions.


-----

