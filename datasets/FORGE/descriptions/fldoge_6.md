#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L472

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L472|

```
numTokensSellToAddToLiquidity = (_tTotal * 5 / 10000) * 10 ** _decimals
_maxTxAmount = (_tTotal * 5 / 1000) * 10 ** _decimals

```

##### Recommendation

The multiplications should be prior to the divisions.