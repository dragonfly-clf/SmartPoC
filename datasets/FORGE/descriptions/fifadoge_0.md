#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L658,677,757

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount or
```
_walletMax to zero.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L658,677,757|

```
if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
  require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
}

```
```
if(checkWalletLimit && !isWalletLimitExempt[recipient])
  require(balanceOf(recipient).add(finalAmount) <= _walletMax);

```

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the _totalTaxIfSelling to
a high value. This will make the contract to operate as a honeypot.

```
if(isMarketPair[sender]) {
  feeAmount = amount.mul(_totalTaxIfBuying).div(100);
}
else if(isMarketPair[recipient]) {
  feeAmount = amount.mul(_totalTaxIfSelling).div(100);
}

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

