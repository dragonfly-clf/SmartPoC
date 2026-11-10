#### ST - Stops Transactions

|Criticality|Critical|
|---|---|
|Location|RichRabbitToken.sol#L1110|
|Status|Unresolved|


##### Description


The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the
```
amountToBlackAfterLaunch to a high value. As a result, the contract may operate

```
as a honeypot.


##### Recommendation


The contract should not be able to block the users from selling their tokens after the
purchase.


-----

