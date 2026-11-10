#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L1069

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1069|

```
fees = amount.mul(totalFees).div(100)
transferToMarketingWallet(address(marketingWallet),address(this).balance.div(10
** 2).mul(marketingDivisor))

```

##### Recommendation

The multiplications should be prior to the divisions.