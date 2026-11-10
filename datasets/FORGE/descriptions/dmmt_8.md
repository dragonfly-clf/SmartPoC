#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L1562,1580

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1562,1580|


tBurn = tAmount.div(100).mul(_burnFee)
tMarketing = tAmount.div(100).mul(_marketingFee)


##### Recommendation

The multiplications should be prior to the divisions.