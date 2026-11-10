## QSP-31 Rari Governance Tokens can still be claimed after distribution ends

#### Severity: Undetermined

 Status: Acknowledged

###### File(s) affected: RariFundToken.sol

 Description: There is a recurring condition that appears in 6 methods inside the RariFundToken contract, namely: if (address(rariGovernanceTokenDistributor) !=

```
address(0) && block.number > rariGovernanceTokenDistributor.distributionStartBlock()), which appears in the following functions: transfer, transferFrom,

###### mint burn,, burnFromand fundManagerBurnFrom. This condition does not check whether the current block number is past the end block of the distribution.

 Recommendation: Clarify if Rari Governance Tokens can still be claimed after distribution ends. If this should not be allowed, then add the following clause to the conjunction: block.number

```
```
< rariGovernanceTokenDistributor.distributionEndBlock()

```

###### .


###### Update from dev team:


###### Rari Governance Tokens can indeed be claimed at any time after the starting block of the distribution period.


