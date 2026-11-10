## QSP-13 Off-by-one error

#### Severity: Low Risk

 Status: Mitigated

###### File(s) affected: RariFundToken.sol

 Description: There is a recurring condition that appears in 6 methods inside the RariFundToken contract, namely: if (address(rariGovernanceTokenDistributor) !=

```
address(0) && block.number > rariGovernanceTokenDistributor.distributionStartBlock()), which appears in the following functions: transfer, transferFrom,

###### mint burn,, burnFromand fundManagerBurnFrom. The second clause in the aforementioned condition is off-by-one, because it only allows claiming RGT one block after the distribution has started.

 Recommendation: Change the sign from > to >= such that the if-condition will allow claiming RGT as soon as distribution starts.

```

###### Update from dev team:


###### No Rari Governance Tokens have been distributed at block zero of the distribution period. Only in the next block have any tokens been distributed.


