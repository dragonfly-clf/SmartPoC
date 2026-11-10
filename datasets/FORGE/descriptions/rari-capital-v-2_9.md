## QSP-10 Missing input argument validation

#### Severity: Low Risk

 Status: Mitigated

###### File(s) affected: RariFundController.sol, RariFundManager.sol, RariFundProxy.sol, AavePoolController.sol

 Description: The following functions are missing validation of input arguments:

#### 1. upgradeFundController does not validate the input parameter newContract, which could lead to sending all funds to any EOA. Fixed

 2. setFundManager does not validate the input parameter newContract, which could lead to setting the fund manager to any EOA.

 3. setFundController does not validate the input parameter newContract, which could lead to setting the fund controller to any EOA.


#### 4. authorizeFundManagerDataSource does not validate the input parameter authorizedFundManagerDataSource, which could lead to setting a data source value of 0x0
 for the fund manager.

 5. setFundToken does not validate the input parameter newContract, which could lead to setting the token to any EOA.

 6. setFundProxy does not validate the input parameter newContract, which could lead to setting the proxy to any EOA.

##### 7. setGsnTrustedSigner does not validate the input parameter newAddress, which could lead to setting the fund manager to 0x0.

#### 8. setInterestFeeRate() should ensure that the rate is <= 10**18. Fixed

###### Recommendation: Add input argument validation to every function where it is needed. Check if addresses are different from 0x0 and/or if necessary check if addresses represent smart
 contracts or EOAs.


###### Update: Only 2 out of the 8 items above have been fixed. From the dev team: "We have added additional input validation where necessary, particularly in upgradeFundController."

