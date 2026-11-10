## QSP-25 Privileged Roles and Ownership (2)

#### Severity: Informational

 Status: Acknowledged

###### File(s) affected: RariFundToken.sol (all repos), RariGovernanceTokenDistributor.sol, RariFundController.sol in rari-ethereum-pool-fund

 Description: 1. The minter of the RariFundToken is allowed to set the rariGovernanceTokenDistributor address to any value at any point in time (even if the new


###### rariGovernanceTokenDistributor is disabled) if the force parameter is set to true. It is not clear how, when or why the force parameter would be used in
```
setGovernanceTokenDistributor()to prevent reverting if the validation checks existent in that function would fail.

#### 1. The owner of the RariGovernanceTokenDistributor contract can:

```
          - Enable and disable the distribution at any time, multiple times.

          - Set the governance token, fund token and fund manager addresses to any non-zero address when the distribution is disabled.

          - Upgrade the contract address to any address, which transfers all RGTs to that address.


#### 2. The owner of RariFundController can set the address of the _rariFundManagerContract to any address including a EOA and then use that address to withdraw all
 the funds from all pools using the withdrawToManager and/or withdrawFromPoolKnowingBalanceToManager functions.

 3. The owner of the RariFundManager can:

          - Upgrade the fund manager contract.

          - Authorize any address to be the fund manager data source.

          - Set the fund controller, fund proxy, fund rebalancer and fund token to any address.

          - Set the interest fee rate to values even higher than 100%.

          - Set the interest fee master beneficiary to any address different from zero.


###### Recommendation:


###### Warn end-users about this privileged action that a minter can make and about the consequences via publicly available documentation. Consider adding a validity check for


###### when force can be set to true.

 Update from dev team: We have added a warning to end-users about the privileges of the contract administrators and their potential consequences in CONCEPT.md. However, we will soon be


###### relinquishing control of the contracts to the Rari Governance Token holders.

