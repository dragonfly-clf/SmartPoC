## QSP-33 Expired cache

#### Severity: Undetermined

 Status: Acknowledged

###### File(s) affected: RariFundManager.sol

 Description: The functions _depositTo, _withdrawFrom, and withdrawFees in RariFundManager.sol@rari-ethereum-pool-fund do not update _rawFundBalanceCache at all, which is different from the behavior of the same functions in the other repositories: rari-staple-pool-contracts and rari-yield-pool-contracts.


###### Recommendation: Clarify if this behavior is intentional. If not, update the _rawFundBalanceCache similarly to the other repos.

 Update from dev team: Usage of _rawFundBalanceCache was temporarily removed in the Rari Ethereum Pool, but we will be restoring this code in a later version of the contracts.


