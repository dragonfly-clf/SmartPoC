#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L474,541

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

|Criticality|critical|
|---|---|
|Location|contract.sol#L474,541|

```
if(!authorizations[sender] && !authorizations[recipient]){
  require(tradingOpen,"Trading not open yet");
}

```

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the sellMultiplier to a
high value. This will make the contract operate as a honeypot.

```
uint256 multiplier = transferMultiplier;
if(recipient == pair){
  multiplier = sellMultiplier;
} else if(sender == pair){
  multiplier = buyMultiplier;
}
uint256 feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator *
100);

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

About the fees read the recommendation in the corresponding section.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

