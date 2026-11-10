#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L448

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting a high value to
```
sellFeeMultiplier. This action can happen only after the 57600th block number

```
since the token’s first transaction. Read more on the fees manipulation finding.

|Criticality|critical|
|---|---|
|Location|contract.sol#L448|

```
} else if(isSell) {
  applySellFeeMultiplier();
}

```

##### Recommendation

The contract could embody a check for not allowing setting the
```
sellFeeMultiplier more than a reasonable amount. A suggested implementation

```
could check that the maximum amount should be more than a fixed percentage of
the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

