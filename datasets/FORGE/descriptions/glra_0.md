#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L912

##### Description

The contract owner has the authority to stop sales for all users excluding the owner.
The owner may take advantage of it by setting the sellTaxes to a high value. The
contract could operate as a honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L912|

```
} else if(to == address(uniswapV2Pair)) {
  tax += baseUnit * sellTaxes["marketing"];

```

##### Recommendation

The contract could embody a check for not allowing setting the sellTaxes more than
a reasonable amount. A suggested implementation could check that the maximum
amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

