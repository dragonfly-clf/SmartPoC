#### ST - Stops Transactions

**Criticality** critical

**Location** contract.sol#L567

**Status** Unresolved

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the maxSellLimit to zero. As a
result, the contract may operate as a honeypot. Additionally, the owner has the
authority to stop transactions by setting maxBuyLimit and maxWalletLimit to zero.

|Criticality|critical|
|---|---|
|Location|contract.sol#L567|
|Status|Unresolved|


if (from == pair && !_isExcludedFromFee[to] && !swapping) {

**require(amount <= maxBuyLimit, "You are exceeding maxBuyLimit");**
**require(**

**balanceOf(to) + amount <= maxWalletLimit,**
**"You are exceeding maxWalletLimit"**
**);**
}

if (

from != pair && !_isExcludedFromFee[to] && !_isExcludedFromFee[from] && !swapping
) {

**require(amount <= maxSellLimit, "You are exceeding maxSellLimit");**
if (to != pair) {

**require(**

**balanceOf(to) + amount <= maxWalletLimit,**
**"You are exceeding maxWalletLimit"**
**);**
}
if (coolDownEnabled) {

uint256 timePassed = block.timestamp - _lastSell[from];
require(timePassed >= coolDownTime, "Cooldown enabled");
_lastSell[from] = block.timestamp;
}
}


-----

##### Recommendation

The contract could embody a check for not allowing setting the maxSellLimit,
maxBuyLimit, and maxWalletLimit less than a reasonable amount. A suggested
implementation could check that the maximum amount should be more than a fixed
percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

