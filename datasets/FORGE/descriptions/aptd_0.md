#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L751, 806

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _ tradingOpen to true and
convert the contract into a honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L751, 806|

```
if (!isAuthorized[sender]) {
       require(tradingOpen, "Trading not open yet");
    }

```

The owner can also convert it into a honeypot and prevent users from selling by
setting the sellTotalFees to a very high value.

```
if (to == pair) {
       feeAmount = amount.mul(sellTotalFees).div(100);
    }

```

##### Recommendation

The contract could embody a check for not allowing setting the sellTotalFees less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

