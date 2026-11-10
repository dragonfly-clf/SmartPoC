#### L08 - Tautology or Contradiction

**Criticality** minor / informative

**Location** contract.sol#L1480,1201

**Status** Unresolved

##### Description

Detects expressions that are tautologies or contradictions. For instance, an uint
variable will always be greater than or equal to zero.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1480,1201|
|Status|Unresolved|


require(bool,string)(rewardFee >= 0 && rewardFee <= maxTaxFee,RF err)
require(bool,string)(fee.setBurnFee >= 0 && fee.setBurnFee <= maxBurnFee,BF err)
require(bool,string)(fee.setRewardFee >= 0 && fee.setRewardFee <= maxTaxFee,RF err)
require(bool,string)(walletCharityFee >= 0 && walletCharityFee <= maxWalletFee,WFT err)
require(bool,string)(taxFee >= 0 && taxFee <= maxTaxFee,TF err)
require(bool,string)(buybackFee >= 0 && buybackFee <= maxBuybackFee,BBF err)
require(bool,string)(fee.setBuybackFee >= 0 && fee.setBuybackFee <= maxBuybackFee,BBF err)
require(bool,string)(fee.setLiqFee >= 0 && fee.setLiqFee <= maxLiqFee,LF err)
require(bool,string)(burnFee >= 0 && burnFee <= maxBurnFee,BF err)
...


##### Recommendation

Fix the incorrect comparison by changing the value type or the comparison.


-----

