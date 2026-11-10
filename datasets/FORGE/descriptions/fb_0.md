#### ST - Stops Transactions

**Criticality** critical

**Location** contract.sol#L955,926

**Status** Unresolved

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the buyTaxFee to a high
value. As a result, the contract may operate as a honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L955,926|
|Status|Unresolved|

```
if(sender == pairAddress) {
  taxFee = amount.mul(buyTaxFee).div(10000);
}

```

The contract owner has the authority to stop the transactions for all users excluding
the owner. The owner may take advantage of it by setting the antiBotAmount to
zero.

```
if (!(addLPaddress[sender] || addLPaddress[recipient]))
    { require(amount <= antiBotAmount, "antiBot"); }

```

##### Recommendation

The contract could embody a check for not allowing setting the ‘antiBotAmount’
less than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

Read more about the fees manipulation.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

