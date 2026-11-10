#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L509,619,884

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L509,619,884|

```
liquidityBalance = _gonBalances[pair].div(_gonsPerFragment)
_gonBalances[autoLiquidityReceiver] =
_gonBalances[autoLiquidityReceiver].add(gonAmount.div(feeDenominator).mul(liquid
ityFee))
_gonBalances[address(this)] =
_gonBalances[address(this)].add(gonAmount.div(feeDenominator).mul(_operationalFe
e.add(sstakeInsuranceFundFee)))
_gonBalances[incinerator] =
_gonBalances[incinerator].add(gonAmount.div(feeDenominator).mul(incineratorFee))
feeAmount = gonAmount.div(feeDenominator).mul(_totalFee)
times = deltaTime.div(900)

```

##### Recommendation

The multiplications should be prior to the divisions.