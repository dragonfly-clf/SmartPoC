## QSP-28 Unexpected pool

#### Severity: Informational

 Status: Acknowledged

###### File(s) affected: RariGovernanceTokenDistributor.sol

 Description: In RariGovernanceTokenDistributor.sol@rari-governance-contracts, the functions setFundManager setFundToken, beforeFirstPoolTokenTransferIn,, getUnclaimedRgt _claimRgt, claimRgt, and refreshDistributionSpeeds have an input parameter called pool of type RariPool, which is an enum with 3 values. When end-users
 call these functions they will be able to pass in an integer value for this parameter, which could be higher than 2, which is the highest value allowed by the enum. This will cause the function to throw without any explicit error message and might be confusing to the end-user as to why the function reverted.


###### Recommendation: These functions should have a require statement that the input parameter pool is strictly smaller than 3 and if not it should revert with an error message that tells the user
 to only use pool values less than 3.


###### Update from dev team:


###### This input validation function will be added in the next version of the contracts.


