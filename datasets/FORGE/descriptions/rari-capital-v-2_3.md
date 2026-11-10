## QSP-4 Divergent mirrored states

#### Severity: Medium Risk

 Status: Acknowledged

###### File(s) affected: RariFundManager.sol, RariFundController.sol, RariFundProxy.sol

 Description: There are several state variables that are mirrored in the following contracts: RariFundManager, RariFundController and RariFundProxy, namely:

#### 1. _fundDisabled: Boolean that, if true, disables the primary functionality of the contract.

 2. _rariFundRebalancerAddress: Address of the rebalancer.

 3. _supportedCurrencies: Array of currencies supported by the fund.

 4. _erc20Contracts: Maps ERC20 token contract addresses to supported currency codes.

 5. _currencyDecimals: Maps decimal precisions (number of digits after the decimal point) to supported currency codes.

 6. _poolsByCurrency: Maps arrays of supported pools to currency codes.

###### During development (before deployment), this creates ambiguity which makes maintainability difficult and error prone, because developers: (1) might forget to update all the values of these

 state variables in all contracts they occur or they (2) might update the state variables with different values in different contracts. For example if new supported currencies are added any of the
 following input parameters could be set differently for different contracts: currencyCode, erc20Contract, decimals and pool. This would have a significant impact on the system as a
 whole.

 After deployment the value of:


#### 1. _fundDisabled can be set independently in different contracts by calling the disableFund and enableFund functions, which could lead the fund to be disable in one
 contract and enabled in the other contract. This can have an important impact on deposits, withdrawals, orders and/or approvals performed by end-users, when values

 are set differently during the small time window in which the 2 separate function calls are performed.

 2. _rariFundRebalancerAddress can be set independently in different contracts by calling the setFundRebalancer function. This can have an important impact on
 deposits, withdrawals, orders and/or approvals performed by end-users, when values are set differently during the small time window in which the 2 separate function

 calls are performed.


###### Recommendation:


###### Since these 3 contracts already have references to each other, we recommend only storing this information in one of the contracts and allowing the other contracts to access


###### the state variables of the former contract (possibly via getter methods).


###### Update:


###### From the dev team: "We certainly agree that ideally, we converge these mirrored states, but we did this to save gas, which happens to be a significant amount. We are aware of the risks


###### associated with these mirrored states and we would certainly catch a mistake pretty easily since the tests would fail. We have ensured that our tests would catch such an error."

