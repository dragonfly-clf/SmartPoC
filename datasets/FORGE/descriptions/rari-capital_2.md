## QSP-3 Gas Usage / for Loop Concerns

#### Severity: Medium Risk

 Status: Mitigated

###### File(s) affected: RariFundController.sol, RariFundManager.sol RariFundProxy.sol,


###### Description: Gas usage is a main concern for smart contract developers and users, since high gas costs may prevent users from wanting to use the smart contract. Even worse, some gas usage
 issues may prevent the contract from providing services entirely. For example, if a for loop requires too much gas to exit, then it may prevent the contract from functioning correctly entirely. The following instances have been found in the code base:

#### 1. The nested for-loops inside upgradeFundManager could reach an out-of-gas error if the total number of pools for all currencies becomes large enough. This would


#### prevent upgrades of RariFundManager.sol.

 2. The nested for-loops inside upgradeFundContoller could reach an out-of-gas error if the total number of pools for all currencies becomes large enough. This would


#### prevent upgrades of RariFundController.sol.

 3. The loop inside setFundManager could reach an out-of-gas error if the number of supported currencies was too high.

 4. The withdrawAndExchange function could reach an out-of-gas error if the number of inputCurrenyCodes was too high.

 5. getAllBalances in RariFundController contains nested loops and a call to potentially expensive external functions inside the inner loop.

 6. marketSell0xOrdersFillOrKill contains a loop with calls to to potentially expensive external functions and could reach an out-of-gas error if the number of orders

 was too high.

##### 7. checkLossRateLimit contains a loop and could reach an out-of-gas error if the _lossRateHistory was too long.

#### 8. cachePoolBalances contains nested loops and could reach an out-of-gas error if the number of supported currencies and number of pools was too high.

##### 9. The loop inside _withdrawFrom could reach an out-of-gas error if the number of pools for a given currency code was too high.


#### 10. The exchangeAndDeposit and the withdrawAndExchange functions in RariFundProxy.sol use transfer() instead of call.value() on L203 and L259, respectively.

 This might have issues when gas cost changes in the future. This has happened in the Istanbul hard fork, which increased the cost such that several existing smart

 contracts which were using transfer() broke due to out-of-gas errors. We anticipate that gas cost will continue to change in the future.


#### 11. The marketSell0xOrdersFillOrKill function in RariFundController.sol uses transfer() instead of call.value() on L524. This might have issues when gas cost

 changes in the future.

 12. The upgrade approach in initNetDeposits() might not be feasible if there are a significant number of users. Consider proxy storage approaches instead.

###### Recommendation:

#### 1. Avoid loops wherever possible. Otherwise, perform gas analysis and determine the limit where the function would reach an out-of-gas error. This limit should be

 enforced using checks in the code.

 2. Replace calls to transfer() with call.value().

 3. Consider proxy storage approaches for upgrades.

###### Update: From the dev team: “Fortunately, we can upgrade any function broken due to excessive gas usage as long as we can run withdrawAllFromPool for each currency of each pool and upgradeFundController(address payable newContract, address erc20Contract) individually for each currency (no loops to worry about in either of these functions). We have
 replaced calls to transfer() with call.value(). We have removed interestAccruedBy, in turn removing initNetDeposits. We have implemented proxy storage for most contracts.”


-----

