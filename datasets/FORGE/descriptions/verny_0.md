#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L662

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.
The owner can also stop all selling actions by increasing sell fees to 100%. This will
convert the contract into a honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L662|

```
       if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
         require(amount <= _maxTxAmount, "Transfer amount exceeds the
maxTxAmount.");
       }

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected

The team has renounced ownership and this danger no longer applies.


-----

