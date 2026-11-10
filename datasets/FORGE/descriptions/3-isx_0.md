#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1484

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the ‘setAllFeePercentfunction’ with the
highest acceptable value for each argument. As a result, the fees could be set up to
60%.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1484|


function setAllFeePercent(

uint8 taxFee,
uint8 liquidityFee,
uint8 burnFee,
uint8 walletFee,
uint8 buybackFee,
uint8 walletCharityFee,
uint8 rewardFee
) external onlyOwner {

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
//both tax fee and reward fee cannot be set
require(rewardFee == 0 || taxFee == 0, "RT fee err");


##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

