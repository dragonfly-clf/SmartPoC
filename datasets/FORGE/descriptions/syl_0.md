#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L658, 760

**Status** Resolved

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

|Criticality|critical|
|---|---|
|Location|contract.sol#L658, 760|
|Status|Resolved|

```
if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
         require(amount <= _maxTxAmount, "Transfer amount exceeds the
maxTxAmount.");
       }

```

The contract owner can also convert the contract into a honeypot and prevent
users from selling by increasing the selling taxes.

```
else if(isMarketPair[recipient]) {
       feeAmount = amount.mul(_totalTaxIfSelling).div(100);
    }

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply. It
could also not allow the _totalTaxIfSelling to be higher than a reasonable amount.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Updated 26 August 2022
The team has renounced ownership and resolved the issues.


-----

