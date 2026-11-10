## QSP-27 Single point of failure for price feeds

#### Severity: Informational

 Status: Acknowledged

###### File(s) affected: RariGovernanceTokenDistributor.sol, RariFundPriceConsumer.sol

 Description: The price feeds rely on a single oracle, namely the Chainlink Aggregator V3, which is indeed robust. However, in the event of any large scale attack/disruption of the Chainlink
 network, Rari Capital would be impacted severely.


###### Recommendation:


###### Consider adding at least one other robust price feed, which is independent of Chainlink.


###### Update from dev team: We plan to add another robust price feed independent of Chainlink in the next version of our contracts, likely the Coinbase price oracle.

