#### L13 - Divide before Multiply Operation

**Criticality** minor / informative

**Location** contract.sol#L1850

**Status** Unresolved

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1850|
|Status|Unresolved|


spentAmount = contractTokenBalance.div(totFee).mul(_rewardFee)
spentAmount = contractTokenBalance.div(totFee).mul(_walletCharityFee)
spentAmount = contractTokenBalance.div(totFee).mul(_buybackFee)
spentAmount = contractTokenBalance.div(totFee).mul(_walletFee)
spentAmount = contractTokenBalance.div(totFee).mul(_burnFee)


##### Recommendation

The multiplications should be prior to the divisions.


-----

