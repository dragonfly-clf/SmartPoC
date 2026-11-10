#### ELFM - Exceeds Fees Limit

**Criticality** Critical

**Location** MarvinInu.sol#L1060,1068

**Status** Unresolved

#### Description

The contract owner has the authority to increase over the allowed limit of 25%. The owner

may take advantage of it by calling the `updateBuyFees` and `updateSellFees`

functions with a high percentage value.
```
   function updateBuyFees(uint256 _marketingFee, uint256
 _liquidityFee, uint256 _devFee) external onlyOwner {
      buyMarketingFee = _marketingFee;
      buyLiquidityFee = _liquidityFee;
      buyDevFee = _devFee;
      buyTotalFees = buyMarketingFee + buyLiquidityFee +
 buyDevFee;
      require(buyTotalFees <= 50, "Must keep fees at 50% or
 less");
   }
   function updateSellFees(uint256 _marketingFee, uint256
 _liquidityFee, uint256 _devFee) external onlyOwner {
      sellMarketingFee = _marketingFee;
      sellLiquidityFee = _liquidityFee;
      sellDevFee = _devFee;
      sellTotalFees = sellMarketingFee + sellLiquidityFee +
 sellDevFee;
      require(sellTotalFees <= 50, "Must keep fees at 50% or
 less");
   }

#### Recommendation

```
The contract could embody a check for the maximum acceptable value. The team should

carefully manage the private keys of the owner’s account. We strongly recommend a


-----

powerful security mechanism that will prevent a single user from accessing the contract

admin functions. Some suggestions are:

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-sign wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

  - Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

