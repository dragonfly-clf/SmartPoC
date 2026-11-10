#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L1263,1493,2362

##### Description

The contract contains statements that checks if an unsigned integer is greater or
equal to zero. An unsigned integer is always greater or equal to zero. As a result
these expressions are redundant.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1263,1493,2362|

```
require(taxFee >= 0 && taxFee <= maxTaxFee, "TF err");
require(liquidityFee >= 0 && liquidityFee <= maxLiqFee, "LF err");
require(burnFee >= 0 && burnFee <= maxBurnFee, "BF err");
require(walletFee >= 0 && walletFee <= maxWalletFee, "WF err");
require(buybackFee >= 0 && buybackFee <= maxBuybackFee, "BBF err");
require(
  walletCharityFee >= 0 && walletCharityFee <= maxWalletFee,
  "WFT err"
);
require(rewardFee >= 0 && rewardFee <= maxTaxFee, "RF err");
//
if (index >= 0) {

```

##### Recommendation

The contract could remove the redundant expressions.


-----

