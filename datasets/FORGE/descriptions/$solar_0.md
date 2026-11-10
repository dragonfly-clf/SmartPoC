#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L521,L466

##### Description

The contract owner has the authority to stop the sales. The owner may take
advantage of it by setting a high value to the sellMultiplier.

|Criticality|critical|
|---|---|
|Location|contract.sol#L521,L466|

```
uint256 multiplier = isSell ? sellMultiplier : 100;
uint256 feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator *
100);

```

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero or
by setting the tradingOpen to false.

```
require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");

```
```
if(!authorizations[sender] && !authorizations[recipient]){
  require(tradingOpen,"Trading not open yet");
}

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The contract should not allow setting the tradingOpen variable to false once it's
```
true.

```
The contract could embody a check for the maximum acceptable value.


-----

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

