#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L513,517,522

##### Description

The contract owner has the authority to stop the sales for all users. The owner may
take advantage of it by setting the taxAddress to the router address and the tax to
a high number so the calculated amount will be insufficient.

|Criticality|critical|
|---|---|
|Location|contract.sol#L513,517,522|

```
if(taxStatus==true && sender==taxAddress && tax>0){
  _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount
exceeds balance");
  _balances[masterWallet] = _balances[masterWallet].add(amount/100*tax);
  _balances[recipient] = _balances[recipient].add(amount/100*(100-tax));

```

The contract owner has the authority to stop transactions for all users. The owner
may take advantage of it by setting the maxBuyAmount or the maxSellAmount to
zero.

```
if(sender==taxAddress){ // user buy Token
 require(amount<=maxBuyAmount, "You can not buy token larger than maximum
amount");
}
if(recipient==taxAddress){ // user sell Token
 require(amount<=maxSellAmount, "You can not sell token larger than maximum
amount");
}

```

##### Recommendation

The contract could embody a check for not allowing setting the maxSellAmount,
maxBuyAmount less than a reasonable amount. A suggested implementation could
check that the maximum amount should be more than a fixed percentage of the
total supply.

Read more about tax manipulation in the corresponding section.


-----

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

