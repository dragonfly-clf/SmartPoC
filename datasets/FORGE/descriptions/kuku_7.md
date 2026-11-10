#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L919,1109

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L919,1109|

```
convertbaltoone = newBalance.div(5)
onepartliqudity = contractTokenBalance.div(_liquidityFee)
tonePart = tFee.div(_taxFee)
ronePart = rFee.div(_taxFee)

```
...


##### Recommendation

The multiplications should be prior to the divisions.