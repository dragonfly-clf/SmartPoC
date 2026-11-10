#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1117, 1104

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1117, 1104|

```
 if(from != owner() && to != owner()) {
       require(amount <= _maxTxAmount, "Transfer amount exceeds the
maxTxAmount.");
    }

```

The contract owner has also the authority to stop the sales for all users excluding
the owner. He can take advantage of it by setting the sellfees to very high values.
This will convert the contract into a HONEYPOT.

```
  function setSellFee(uint256 sellTaxFee, uint256 sellLiquidityFee) external
onlyOwner {
    _sellTaxFee = sellTaxFee;
    _sellLiquidityFee = sellLiquidityFee;
  }

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount or not allowing the sellfees to be very high values. A
suggested implementation could check that the maximum amount should be more
than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

