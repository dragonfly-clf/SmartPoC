#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L839,853,883

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the _sellAdvestisementFee
to a high value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L839,853,883|

```
}else if(isSell){
  _taxFee = _sellTaxFee;
  _advestisementFee = _sellAdvestisementFee;
}

```

The contract owner has the authority to allow transactions only for specific users.
The owner may take advantage of it by adding addresses to the
```
antibotModeWhitelist and enabling the isAntibotModeEnabled

```
```
if (from == owner() || from == airdropContract) return;
require(antibotModeWhitelist[from] && antibotModeWhitelist[to], "Address not in
antibot mode whitelist");

```

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

```
if(from != owner() && to != owner())
  require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The antibotModeWhitelist should not be able to be manipulated after the launch of
the non-whitelist trading.


-----

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

