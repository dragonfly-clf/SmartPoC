## QSP-18 Incorrect Rari Governance Token amount

#### Severity: High Risk

 Status: Fixed

###### File(s) affected: RariGovernanceToken.sol


###### Description: There is a typo on L27 of RariGovernanceToken.sol, namely 8570000 should be 8750000 according to the comment on L23: "Initializer that reserves 8.75 million RGT for liquidity mining and 1.25 million RGT to the team.". This will conflict with L157 of RariGovernanceTokenDistributor.sol: finalRgtDistribution = 8750000e18.

 Recommendation: Fix the typo such that the amount is correct.

