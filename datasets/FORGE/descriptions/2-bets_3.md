#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L1386

##### Description

Variable swapping will be always assigned to false inside the if statement

|Criticality|minor|
|---|---|
|Location|contract.sol#L1386|

```
if(
  !swapping &&
  !automatedMarketMakerPairs[from] &&
  !_isExcludedFromFees[from] &&
  !_isExcludedFromFees[to]
) {
  swapping = true;
  swapping = false;
}
bool takeFee = !swapping;
// if any account belongs to _isExcludedFromFee account then remove the fee
if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
  takeFee = false;
}
bool takeFee = !_isExcludedFromFees[from] && !_isExcludedFromFees[to]

```

##### Recommendation

The above code segment could be rewritten into the below:

```
bool takeFee = !_isExcludedFromFees[from] && !_isExcludedFromFees[to]

```

-----

