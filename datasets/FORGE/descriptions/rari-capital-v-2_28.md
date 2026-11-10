## QSP-29 Potential funds stuck in contract

#### Severity: Undetermined

 Status: Acknowledged

###### File(s) affected: RariFundProxy.sol

 Description: In withdrawAndExchange(), does there need to be a check that all orders obtain tokens of the same type (corresponding to outputErc20Contract). For example, suppose


###### one order obtained WETH and another contained DAI, and outputErc20Contract = address(0). Wouldn't the DAI funds be stuck in the contract until another withdrawAndExchange()
 transaction occurs with outputErc20Contract = DAI?


###### Recommendation: Add check that all orders obtain tokens of the same type (corresponding to outputErc20Contract)

 Update: From dev team: It costs us a good bit of additional gas to validate all orders, and we want to avoid gas costs as much as possible in the exchangeAndDeposit and

```
withdrawAndExchange

```

###### functions. Assuming the user's client has not made a mistake, lack of validation on the contract side should not be necessary. However, we will write tests to confirm


###### this could not be an issue in the official SDK, which will soon replace this logic in the web client.

