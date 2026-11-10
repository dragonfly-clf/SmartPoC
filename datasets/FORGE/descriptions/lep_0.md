#### ST - Stop Transactions

**Criticality** medium

**Location** contract.sol#L863

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the maxTxAmount to zero or
by setting the openBool to false.

|Criticality|medium|
|---|---|
|Location|contract.sol#L863|

```
   if(!openBool && from!=owner() && to!=owner() && !openUser[from] &&
!openUser[to]){
       require(false,"open is not");
    }
   if(!swappingTwo&& from != owner() && to != owner()&&from==uniswapV2Pair&&
!isbig[to]){
       require(balanceOf(to).add(amount) <= _maxTxAmount, "Transfer amount
exceeds the maxTxAmount.");

```

##### Recommendation

The contract could embody a check for not allowing setting the maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

