#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1326,995,1027

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. He can do that in multiple ways. He can increase the
```
sellFeeIncreaseFactor to a very high percent and convert the contract into a

```
**HONEYPOT**

|Criticality|critical|
|---|---|
|Location|contract.sol#L1326,995,1027|

```
if(automatedMarketMakerPairs[to]) {
  fees = fees.div(100).mul(sellFeeIncreaseFactor);
}

```

He can also convert it into a honeypot and prevent users from selling by setting the
```
maxSellTransactionAmount to zero.

```
```
 else if (
       tradingIsEnabled &&
       automatedMarketMakerPairs[to] &&
       !excludedAccount
    ) {
       require(amount <= maxSellTransactionAmount, "Sell transfer amount
exceeds the maxSellTransactionAmount.");

```

The owner may take advantage of it by setting the maxWalletBalance to zero.

```
 if(!automatedMarketMakerPairs[to] && tradingIsEnabled && !excludedAccount){
       require(balanceOf(to).add(amount) <= maxWalletBalance, 'Wallet
balance is exceeding maxWalletBalance');
    }

```

##### Recommendation

The contract could embody a check for not allowing setting the
maxSellTransactionAmount and maxWalletBalance less than a reasonable amount.


-----

A suggested implementation could check that the maximum amount should be
more than a fixed percentage of the total supply.

He could also not allow the sellFeeIncreaseFactor to be higher than a reasonable
amount.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

