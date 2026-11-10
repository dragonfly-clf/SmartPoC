## QSP-40 No example of token distribution implementation is presented

#### Severity: Undetermined

 Status: Fixed

###### File(s) affected: rari-ethereum-pool-contracts/.../IRariGovernanceTokenDistributor.sol

 Description: distributionEndBlock is a critical parameter used on the interface for governance distribution IRariGovernanceTokenDistributor. This method is only called in


###### RariFundManager when the block number is below distributionEndBlock. No example implementation of IRariGovernanceTokenDistributor is presented, and

```
distributionEndBlock

```

###### must be used there to make this parameter effective.


###### Recommendation: Make sure to include an example implementation and check that after block number distributionEndBlock that minting cannot be executed.
 Update from the Rari Capital team: Tests for token distribution are available in rari-governance-contracts, which test both the governance token distribution contracts and the pool contracts in

 tandem.

