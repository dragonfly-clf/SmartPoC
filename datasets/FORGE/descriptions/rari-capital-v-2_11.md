## QSP-12 ETH/USD prices could be stale

#### Severity: Low Risk

 Status: Acknowledged

###### File(s) affected: RariGovernanceTokenDistributor.sol, RariFundPriceConsumer.sol

 Description: The following functions do not check if the ETH/USD price is stale:

#### 1. RariGovernanceTokenDistributor.getEthUsdPrice in rari-governance-contracts

 2. RariFundPriceConsumer.getDaiUsdPrice in rari-stable-pool-contracts and rari-yield-pool-contracts

 3. RariFundPriceConsumer.getEthUsdPrice in rari-stable-pool-contracts and rari-yield-pool-contracts


-----

#### 4. RariFundPriceConsumer.getPriceInEth in rari-stable-pool-contracts and rari-yield-pool-contracts.

###### According to the Chainlink documentation:

#### • under current notifications: "if answeredInRound < roundId could indicate stale data."

 • under historical price data: "A timestamp with zero value means the round is not complete and should not be used."

###### Recommendation: We recommend adding require statements that check for the aforementioned conditions in all the occurrences of those functions.


###### Update from dev team:


###### We will add validation to check if the ETH/USD price is stale in the next version of the contracts.


