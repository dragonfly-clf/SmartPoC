## QSP-25 Duration of RGT distribution may be different from 60 days

#### Severity: Informational

 Status: Fixed

###### File(s) affected: RariGovernanceTokenDistributor.sol

 Description: The duration of the distribution period is set to 345600 blocks on L152 in RariGovernanceTokenDistributor.sol. Assuming that the average block duration over a 60 day
 period is 15 seconds results in 60 days. However, according to the latest statistics on Etherscan we foresee an average block duration of 13 seconds, which would reduce the distribution period to 52 days. However, this is also an approximate estimate as the actual duration could be even lower.


###### Recommendation: Add information to the user-facing documentation, which indicates that the duration of the distribution period is 345600 blocks starting with which block such that it is clear
 to end-users when the distribution period ends.

 Update from dev team: The distribution period has been changed to 390000 blocks (i.e., 6500 blocks per day or approximately 13.292 seconds per block). We have added the suggested
 notice to README.md and CONCEPT.md.

