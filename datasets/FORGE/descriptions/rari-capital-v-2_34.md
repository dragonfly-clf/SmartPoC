## QSP-35 Missing input validation

#### Severity: Low Risk

 Status: Acknowledged

###### File(s) affected: RariFundController.sol, RariFundManager.sol

 Description: The following function should perform additional checks:

#### 1. RariFundController.setEnzymeComptroller should ensure that comptroller is non-zero.

 2. RariFundController.marketSell0xOrdersFillOrKill should ensure that inputErc20Contract is non-zero.

 3. RariFundController.setFundManager should ensure that newContract is non-zero.

 4. RariFundController.setFundRebalancer should ensure that newAddress is non-zero.

 5. RariFundManager.authorizeFundManagerDataSource should ensure that authorizedFundManagerDataSource is non-zero.

 6. RariFundManager.setFundController should ensure that newContract is non-zero.

##### 7. RariFundManager.setFundToken should ensure that newContract is non-zero.

#### 8. RariFundManager.setFundProxy should ensure that newContract is non-zero.

##### 9. RariFundManager.setFundRebalancer should ensure that newContract is non-zero.

###### Recommendation: Add corresponding require statements to above.

