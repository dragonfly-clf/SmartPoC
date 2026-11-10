#### ELFM - Exceeds Fees Limit

**Criticality** Critical

**Location** CiccaDefi.sol#L1139

**Status** Unresolved

#### Description

The contract owner has the authority to increase over the allowed limit of 25%. The owner

may take advantage of it by calling the `setTaxFeePercent` function with a high

percentage value.
```
 function setTaxFeePercent(uint256 taxFee) external onlyOwner()
 {
   _taxFee = taxFee;
 }
 function setLiquidityFeePercent(uint256 liquidityFee) external
 onlyOwner() {
   _liquidityFee = liquidityFee;
 }
 function setStakingFeePercent(uint256 stakingFee) external
 onlyOwner() {
   _stakingFee = stakingFee;
 }

#### Recommendation

```
The contract could embody a check for the maximum acceptable value. The team should

carefully manage the private keys of the owner’s account. We strongly recommend a

powerful security mechanism that will prevent a single user from accessing the contract

admin functions.

Temporary Solutions:

These measurements do not decrease the severity of the finding

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-signature wallet so that many addresses will confirm the action.


-----

  - Introduce a governance model where users will vote about the actions.

Permanent Solution:

  - Renouncing the ownership, which will eliminate the threats but it is non-reversible.


-----

