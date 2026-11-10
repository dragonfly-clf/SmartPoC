#### L08 - Tautology or Contradiction

**Criticality** minor

**Location** contract.sol#L1201,1480

##### Description

Detects expressions that are tautologies or contradictions. For instance, an uint
variable will always be greater than or equal to zero.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1201,1480|


require(bool,string)(fee.setRewardFee >= 0 && fee.setRewardFee <= maxTaxFee,RF err)
require(bool,string)(fee.setLiqFee >= 0 && fee.setLiqFee <= maxLiqFee,LF err)
require(bool,string)(liquidityFee >= 0 && liquidityFee <= maxLiqFee,LF err)
require(bool,string)(walletCharityFee >= 0 && walletCharityFee <= maxWalletFee,WFT err)
require(bool,string)(fee.setBuybackFee >= 0 && fee.setBuybackFee <= maxBuybackFee,BBF err)
require(bool,string)(taxFee >= 0 && taxFee <= maxTaxFee,TF err)
require(bool,string)(fee.setWalletCharityFee >= 0 && fee.setWalletCharityFee <=
maxWalletFee,WFT err)
require(bool,string)(walletFee >= 0 && walletFee <= maxWalletFee,WF err)
require(bool,string)(buybackFee >= 0 && buybackFee <= maxBuybackFee,BBF err)
...


##### Recommendation

Fix the incorrect comparison by changing the value type or the comparison.


-----

