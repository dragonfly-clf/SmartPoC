#### ST - Stop Transactions

**Criticality** medium

**Location** contract.sol#L429

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the tradingOpen to false.

|Criticality|medium|
|---|---|
|Location|contract.sol#L429|

```
if(!authorizations[sender] && !authorizations[recipient]){
     require(tradingOpen,"Trading not open yet");
   }

```

There is also a _maxWalletToken variable that can be set to any value. If the owner
configures this variable to be a low number it can potentially fail transactions as
well.

##### Recommendation

The contract could embody a check for not allowing setting the _maxWalletToken
less than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

