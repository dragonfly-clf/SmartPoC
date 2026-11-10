#### CR - Code Repetition

**Criticality** minor

**Location** contract.sol#L1331

##### Description

There are code segments that are repetitive in the contract. Those segments
increase the code size of the contract unnecessarily.

The swapManual() method could be reused by the transfer’s swap feature.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1331|

```
swapping = true;
if(AmountMarketingFee > 0) swapAndSendToFee(AmountMarketingFee);
if(AmountLiquidityFee > 0) swapAndLiquify(AmountLiquidityFee);
if(AmountTokenRewardsFee > 0) swapAndSendDividends(AmountTokenRewardsFee);
if(AmountGasFee > 0) swapAndGasFee(AmountGasFee);
if(AmountExternalFee > 0) swapAndExternalFee(AmountExternalFee);
swapping = false;

```

##### Recommendation

Create an internal function that contains the code segment and remove it from all
the sections.


-----

