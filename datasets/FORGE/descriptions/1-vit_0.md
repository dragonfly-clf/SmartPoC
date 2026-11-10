#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L752, 771, 859

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner can do that in multiple ways. The owner may take advantage of it
by setting the _maxTxAmount to zero.

|Criticality|critical|
|---|---|
|Location|contract.sol#L752, 771, 859|

```
if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
         require(amount <= _maxTxAmount, "Transfer amount exceeds the
maxTxAmount.");
       }

```

The contract owner can also stop transactions by setting the _walletMax to zero.

```
if(checkWalletLimit && !isWalletLimitExempt[recipient])
         require(balanceOf(recipient).add(finalAmount) <= _walletMax);

```

The owner can also convert the contract into a honeypot and prevent users from
selling by setting the _totalTaxIfSelling to a high percentage value.

```
 else if(isMarketPair[recipient]) {
       feeAmount =
amount.mul(_totalTaxIfSelling.sub(_sellDestroyFee)).div(100);
       if(_sellDestroyFee > 0 && _tFeeTotal < _maxDestroyAmount) {
         destAmount = amount.mul(_sellDestroyFee).div(100);
         destroyFee(sender,destAmount);
       }
    }

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount and
_walletMax less than a reasonable amount. A suggested implementation could
check that the minimum amount should be more than a fixed percentage of the total
supply.


-----

Also, the contract could embody a check for the maximum acceptable value for the
_totalTaxIfSelling. A suggested implementation could check that the maximum
amount should be less than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

