#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L797

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L797|


liquidityFee = amount.mul(_liquidityFee).div(10000)
BurnFee = amount.mul(_BurnFee).div(10000)
marketingFee = amount.mul(_marketingFee).div(10000)
taxFee = amount.mul(_taxFee).div(10000)


##### Recommendation

The multiplications should be prior to the divisions.