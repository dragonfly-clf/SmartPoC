#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L1034,1045,1207,716

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1034,1045,1207,716|

```
maxLimit = _totalSupply.div(100).mul(1)
_maxTxAmount = _totalSupply.div(1000).mul(5)
buyBackTokens(balance.div(100).mul(buybackFactor))

```
...


##### Recommendation

The multiplications should be prior to the divisions.