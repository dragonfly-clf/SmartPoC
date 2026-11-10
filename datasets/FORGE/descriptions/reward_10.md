#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L538,652,943

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L538,652,943|

```
liquidityBalance = _gonBalances[pair].div(_gonsPerFragment)
_gonBalances[riskFreeValueReceiver] =
_gonBalances[riskFreeValueReceiver].add(gonAmount.div(feeDenominator).mul(_riskF
reeValueFee))
_gonBalances[autoLiquidityReceiver] =
_gonBalances[autoLiquidityReceiver].add(gonAmount.div(feeDenominator).mul(_liqui
dityFee))
_gonBalances[address(this)] =
_gonBalances[address(this)].add(gonAmount.div(feeDenominator).mul(_treasuryFee))
_gonBalances[firePit] =
_gonBalances[firePit].add(gonAmount.div(feeDenominator).mul(_firePitFee))
feeAmount = gonAmount.div(feeDenominator).mul(_totalFee)
times = deltaTime.div(rebaseFrequency)

```

##### Recommendation

The multiplications should be prior to the divisions.