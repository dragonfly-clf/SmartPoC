#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L874,915

##### Description

The contract owner has the authority to stop transactions for all users by setting the
variable tradingEnable to false.

The contract owner can also turn this contract into a honeypot and prevent users
from selling their tokens by increasing the sell fees to 100%.

|Criticality|critical|
|---|---|
|Location|contract.sol#L874,915|

```
require(tradingEnable,"trading is disable");
if(recipient == uniswapV2Pair){
 if(!isTaxless[sender] && !isTaxless[recipient] && !inSwapAndLiquify){
      transferAmount = collectSellFee(sender,amount,rate);
}

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

