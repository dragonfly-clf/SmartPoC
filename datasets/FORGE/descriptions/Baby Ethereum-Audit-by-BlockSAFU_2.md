High-Risk

 2 high-risk code issues found

 Must be fixed, and will bring problem.

1. The owner can set fess up to 100%
```
         function setTokenRewardsFee(uint256 value) external onlyOwner
      {
           rewardsFee = value;
           totalFees =
      rewardsFee.add(liquidityFee).add(marketingFee);
         }
         function setLiquiditFee(uint256 value) external onlyOwner {
           liquidityFee = value;
           totalFees =
      rewardsFee.add(liquidityFee).add(marketingFee);
         }
         function setMarketingFee(uint256 value) external onlyOwner {
           marketingFee = value;
           totalFees =
      rewardsFee.add(liquidityFee).add(marketingFee);
         }

```
2. The owner can set blacklist
```
         function blacklistAddress(address account, bool value)
      external onlyOwner {
           isBlacklisted[account] = value;
         }

#### 