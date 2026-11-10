#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1450

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the txfee to a high value.
Additionally, the contract owner has the authority to change the TwentyFourhours
value. As a result the tradeAmount will be stuck and the users will not be able to
sell and their funds will be trapped into a HONEYPOT.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1450|

```
function ActivateAntiWhale(address from,uint amount) private {
  uint blkTime = block.timestamp;
  uint256 onePercent = balanceOf(from).mul(txfee).div(100); //Should use
variable
  require(amount <= onePercent, "ERR: Can't sell more than 1%");
  if( blkTime > tradeData[from].lastTradeTime + TwentyFourhours) {
    tradeData[from].lastTradeTime = blkTime;
    tradeData[from].tradeAmount = amount;
  }
  else if( (blkTime < tradeData[from].lastTradeTime + TwentyFourhours) && ((
blkTime > tradeData[from].lastTradeTime)) ){
    require(tradeData[from].tradeAmount + amount <= onePercent, "ERR: Can't
sell more than 1% in One day");
    tradeData[from].tradeAmount = tradeData[from].tradeAmount + amount;
  }
}

```

##### Recommendation

The contract could embody a check for not allowing setting the txfee and
TwentyFourhours more than a reasonable amount. A suggested implementation
could check that the maximum amount should be more than a fixed percentage of
the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

