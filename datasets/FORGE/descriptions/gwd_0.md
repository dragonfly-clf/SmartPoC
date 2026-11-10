#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L632,647

**Status** Resolved

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the tradingEnabled to false.

|Criticality|critical|
|---|---|
|Location|contract.sol#L632,647|
|Status|Resolved|

```
if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
    require(tradingEnabled, "Trading not active");
  }

```

The contract owner may convert the contract into a Honeypot and prevent users
from selling. He can take advantage of it by setting the maxSellLimit to zero.

```
  if (
       from != pair && !_isExcludedFromFee[to] &&
!_isExcludedFromFee[from] && !swapping
    ) {
       require(amount <= maxSellLimit, "You are exceeding maxSellLimit");
       if (to != pair) {
         require(
           balanceOf(to) + amount <= maxWalletLimit,
           "You are exceeding maxWalletLimit"
    );
  }

```

##### Recommendation

The contract could embody a check for not allowing setting the maxSellLimit less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected 05 April 2022

The owner has renounced contract ownership and the threats have been eliminated.


-----

