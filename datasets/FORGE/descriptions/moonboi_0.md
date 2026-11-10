#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L919

##### Description

The contract owner has the authority to stop all sales excluding the owner. The
owner may take advantage of it by setting the _sellTax to a high value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L919|

```
if(isSell){
  if(!_excludedFromSellLock.contains(sender)){
       //If seller sold less than sellLockTime(2h 50m) ago, sell is
declined, can be disabled by Team
    require(_sellLock[sender]<=block.timestamp||sellLockDisabled,"Seller in
sellLock");
    //Sets the time sellers get locked(2 hours 50 mins by default)
    _sellLock[sender]=block.timestamp+sellLockTime;
  }
  //Sells can't exceed the sell limit(21,000 Tokens at start, can be updated
to circulating supply)
  require(amount<=sellLimit,"Dump protection");
  tax=_sellTax;
} else if(isBuy){

```

##### Recommendation

The contract could embody a check for not allowing setting the _sellTax to a value
that will not allow the transaction to proceed.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

