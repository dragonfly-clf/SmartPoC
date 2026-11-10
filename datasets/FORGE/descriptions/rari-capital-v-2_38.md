## QSP-39 Unclear addPool omission in initialize

#### Severity: Undetermined

 Status: Fixed

###### File(s) affected: rari-eth-pool-contracts/contracts/RariFundManager.sol

 Description: In initialize, it is unclear why addPool(5), which would correspond to Enzyme, is not invoked.

 Recommendation: Clarify if this is omitted intentionally.

