#### ST - Stops Transactions

|Criticality|Medium|
|---|---|
|Location|Nabana.sol#L2076,2130|
|Status|Unresolved|


##### Description


The contract owner has the authority to stop the transactions for all users excluding
the owner. The owner may take advantage of it by setting the



- `minSellTransactionAmount to a high value and/or`

```
maxSellTransactionAmount to zero.

```


- `handleLimitTime to a high value.`


The contract can limit users from selling more than 20% of the circulating supply for
24 hours (initial handleLimitTime value) if their balance is more than 1% of the
```
totalSupply. Moreover, during sales the contract limits the transaction amount to

```
a lower and upper bound (initial values are 0.02% and 2% of the totalSupply
respectively).


##### Recommendation


The contract could embody a check for not allowing setting the
minSellTransactionAmount more than a reasonable amount and/or
maxSellTransactionAmount less than a reasonable amount. A suggested
implementation could check that the maximum/minimum amount should be
more/less than a fixed percentage of the total supply.

Respectively the handleLimitTime variable should be able to be configured no
more than a reasonable time period. The team could exploit the error message that
says try again after 24 hours. Currently, the contract owner can set any value
to the handleLimitTime.


-----

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

