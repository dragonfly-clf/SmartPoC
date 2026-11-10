#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L912

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the sellTaxes to high values.
As a result, the user’s balance will not be sufficient, the expression will overflow and
the transaction will revert.

|Criticality|critical|
|---|---|
|Location|contract.sol#L912|

```
} else if(to == address(uniswapV2Pair)) {
  tax += baseUnit * sellTaxes["marketing"];
  tax += baseUnit * sellTaxes["dev"];
  tax += baseUnit * sellTaxes["liquidity"];
  tax += baseUnit * sellTaxes["charity"];
  if(tax > 0) {
    _transfer(from, address(this), tax);
  }

```

##### Recommendation

Read more in the fees manipulation section.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

