## QSP-32 Upgrading Fund Controller can be done when fund is enabled

#### Severity: Undetermined

 Status: Acknowledged

###### File(s) affected: RariFundController.sol

 Description: In RariFundController.upgradeFundController()function in both the rari-ethereum-pool-fund and rari-stable-pool-contracts repos, it is not required that the fund is disabled, unlike the same function in the rari-yield-pool-contracts repo. It is not clear if this is intentional or not.


###### Recommendation: Clarify if the Fund Controller can be upgraded even when the fund is enabled. If not, add the same require statement from the rari-yield-pool-contracts repo to
 the other 2 repos. Otherwise, remove that require staement.


###### Update from dev team: These updates are planned for the next version of the the rari-stable-pool-contracts and rari- ethereum-pool-contracts repos. When we added this
 feature to the rari-yield-pool-contracts before deployment, we did not consider this single feature important enough to redeploy the existing Stable Pool and Ethereum Pool


###### implementation contracts.


-----

