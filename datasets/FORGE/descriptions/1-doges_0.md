#### ST - Stop Transactions

**Criticality** medium

**Location** contract.sol#L784,789

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount or
```
_maxWalletToken to zero.

```
|Criticality|medium|
|---|---|
|Location|contract.sol#L784,789|

```
require(amount <= _maxTxAmount, "You are trying to buy more than the max
transaction limit.");

```
```
require((heldTokens + amount) <= _maxWalletToken,"You are trying to buy too many
tokens. You have reached the limit for one wallet.");}

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount and
_maxWalletToken less than a reasonable amount. A suggested implementation
could check that the maximum amount should be more than a fixed percentage of
the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected on 7th March 2022

The team has renounced ownership and the threat is no longer applicable.


-----

