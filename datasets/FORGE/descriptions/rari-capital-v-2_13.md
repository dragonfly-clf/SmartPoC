## QSP-14 Missing input argument validation (2)

#### Severity: Low Risk

 Status: Acknowledged

###### File(s) affected: RariFundController.sol, RariFundManager.sol

 Description: The following functions are missing input parameter validation:

#### 1. RariFundController.setFundManager in rari-ethereum-pool-fund does not validate the newContract parameter of type address.

 2. setFundRebalancer in all repos and all contracts does not check the newAddress parameter of type address.

 3. setFundPriceConsumer in all repos does not check the newContract parameter of type address.

###### Recommendation: Add input argument validation to every function where it is needed. Check if addresses are different from 0x0 and/or if necessary check if addresses represent smart
 contracts or EOAs.


###### Update from dev team:


###### These input validation functions will be added in the next version of the contracts.


