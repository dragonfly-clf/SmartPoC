#### L13 - Divide before Multiply Operation

**Criticality** minor / informative

**Location** contract.sol#L1114

**Status** Unresolved

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1114|
|Status|Unresolved|


fees = amount.mul(buyTotalFees).div(100)
tokensForMarketing += fees * sellMarketingFee / sellTotalFees
fees = amount.mul(sellTotalFees).div(100)
tokensForDev += fees * sellDevFee / sellTotalFees


##### Recommendation

The multiplications should be prior to the divisions.


-----

