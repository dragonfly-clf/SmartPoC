#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L486

**Status** Semi-Resolved

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner.

The owner may take advantage of it by setting :

 - tradingEnabled to false.

 - maxSellLimit to zero ( HONEYPOT ).

 - maxWalletLimit to zero.

 - coolDownTime to maximum amount ( HONEYPOT ).

|Criticality|critical|
|---|---|
|Location|contract.sol#L486|
|Status|Semi-Resolved|


if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){

require(tradingEnabled, "Trading not active");
}

if(from != pair && !_isExcludedFromFee[to] && !_isExcludedFromFee[from] && !swapping){

require(amount <= maxSellLimit, "You are exceeding maxSellLimit");
if(to != pair){

require(balanceOf(to) + amount <= maxWalletLimit, "You are exceeding
maxWalletLimit");

}
if(coolDownEnabled){

uint256 timePassed = block.timestamp - _lastSell[from];
require(timePassed >= coolDownTime, "Cooldown enabled");
_lastSell[from] = block.timestamp;
}
}


-----

##### Contract Reverts in Small Amounts

The contract has a hard limit of 10 * 10**decimals(). The contract is able to stop the
transactions if the user’s balance is less than the hard limit. As a result, the
transaction will underflow.


if(balanceOf(from) - amount <= 10 * 10**decimals()) amount -= (10 * 10**decimals() + amount balanceOf(from));


**For instance**

|Balance|9|
|---|---|
|Amount|5|

```
amount -= (10 * 10**decimals() + amount - balanceOf(from)) ->
amount -= 10 + 5 - 9 ->
amount -= 6 ->
5 -= 6

```

##### Recommendation

The contract could embody a check for not allowing setting the maxSellLimit,
maxWalletLimit less than a reasonable amount. A suggested implementation could
check that the maximum amount should be more than a fixed percentage of the
total supply.

The contract could embody a check for not allowing setting the coolDownTime
more than a reasonable amount.

The contract should not have a hard limit for the user’s token.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Updated 03 August 2022

The team has renounced ownership, as a result all the honeypot-related issues have
been resolved. The finding with the contract underflow remains vulnerable since it is
not affected by the contract’s permissions.


-----

