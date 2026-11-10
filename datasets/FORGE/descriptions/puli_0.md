#### ST - Stop Transactions

**Criticality** critical

**Location** https://bscscan.com/address/0xaef0a177c8c329cbc8508292bb7e06c00786bbfc
#L1588

**Status** Multi-Sign

##### Description

The contract owner has the authority to stop transactions for all users trying to sell
their tokens and it will have a honeypot behaviour. The owner may take advantage
of it by setting the maxSellAmount to zero.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0xaef0a177c8c329cbc8508292bb7e06c00786bbfc #L1588|
|Status|Multi-Sign|

```
if (recipient == uniswapV2Pair) {
  require(amount <= maxSellAmount, "Sell exceeds limit");
  setSell();
}

```

The owner can also stop transactions for everyone by setting maxWalletAmount to
the zero value

```
if(recipient != uniswapV2Pair){
        require(
          balanceOf(recipient) + amount <= maxWalletAmount,
          "Balance exceeds limit"
        );
     }

```

##### Recommendation

The contract could embody a check for not allowing setting the maxSellAmount
less than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Updated 17 May 2022

The team has acknowledged the threat and transferred the contract ownership to a
multi-sign mechanism.


-----

