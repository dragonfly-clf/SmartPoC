#### ST - Stops Transactions

**Criticality** critical

**Location** contract.sol#L515, L516, L525, L534

**Status** Unresolved

##### Description

The contract owner has the authority to stop the transactions for all users excluding
the owner. The owner may take advantage of it by setting the maxBuyLimit,
maxWalletLimit or maxSellLimit to zero, or by setting the coolDownTime to a high
value. The contract may operate as a honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L515, L516, L525, L534|
|Status|Unresolved|


require(amount <= maxBuyLimit, "You are exceeding maxBuyLimit");
…
require(balanceOf(to) + amount <= maxWalletLimit, "You are exceeding maxWalletLimit");
…
require(amount <= maxSellLimit, "You are exceeding maxSellLimit");
…
require(timePassed >= coolDownTime, "Cooldown enabled");


##### Recommendation

The contract could embody a check for not allowing setting the maxBuyLimit,
maxWalletLimit or maxSellLimit less than a reasonable amount and coolDownTime
more than a reasonable amount or none at all.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

