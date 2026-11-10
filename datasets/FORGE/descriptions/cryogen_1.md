##### UIF - Unlimited Increase Fees

###### Criticality high

 Location https://bscscan.com/address/0x6a73a99fac60c265863307c5a40abf32f0a040ac#co de#L2704, L2709,L 2714

 Description

 The contract owner has the authority to increase fees without limit. The owner may take advantage of it by calling the fee setter functions like the setLiquiditFee with a high percentage value. Even if the final fee is calculated proportional to the
```
totalFees, if the user set the setLiquiditFee to 100 and all the other fees to 0,
 then the calculated marketing fee will be

```
|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x6a73a99fac60c265863307c5a40abf32f0a040ac#co de#L2704, L2709,L 2714|

```
function setLiquiditFee(uint256 value) external onlyOwner {
  liquidityFee = value;
  totalFees = tokenRewardsFee.add(liquidityFee).add(marketingFee);
}

```

###### Recommendation

 The contract could embody a check for the maximum acceptable value. In the
```
initialize function this check exists. It is missing from the fee setter functions.

 The team should carefully manage the private keys of the owner’s account. We strongly recommend a powerful security mechanism that will prevent a single user from accessing the contract admin functions. That risk can be prevented by temporarily locking the contract or renouncing ownership.

```

-----

