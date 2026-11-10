##### UIF - Unlimited Increase Fees

###### Criticality high

 Location https://bscscan.com/address/0xd8c152d3b94084d7c8ec951e81fbbfc4b6de5b2b# code#L1363,L1379

 Description

 The contract owner has the authority to increase fees without limit. The owner may take advantage of it by calling the setMarketingFee function with a high percentage value.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xd8c152d3b94084d7c8ec951e81fbbfc4b6de5b2b# code#L1363,L1379|

```
 function setMarketingFee(uint256 _marketingFee) external onlyOwner{
    marketingFee = _marketingFee;
    totalFees =
BUSDRewardsFee.add(liquidityFee).add(marketingFee).add(buybackFee);
  }

```

###### Recommendation

 The contract could embody a check for the maximum acceptable value.

 The team should carefully manage the private keys of the owner’s account. We strongly recommend a powerful security mechanism that will prevent a single user from accessing the contract admin functions. That risk can be prevented by temporarily locking the contract or renouncing ownership.


-----

