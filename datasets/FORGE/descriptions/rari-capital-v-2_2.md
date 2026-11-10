## QSP-3 Uninitialized _ethUsdPriceFeed

#### Severity: High Risk

 Status: Fixed

###### File(s) affected: RariGovernanceTokenDistributor.sol in rari-governance-contracts

 Description: The AggregatorV3Interface private _ethUsdPriceFeed state variable defined on L234 in RariGovernanceTokenDistributor.sol is never initialized (assigned a value). However, it is used in the getEthUsdPrice function. This means that the getEthUsdPrice will always return 0, which will affect the Ethereum fund pool of Rari.


###### Recommendation: Initialize the _ethUsdPriceFeed state variable in the initialize function of the contract.


###### Update:


###### This issues was also independently found by the Rari Capital dev team and fixed before the Mainnet deployement.


