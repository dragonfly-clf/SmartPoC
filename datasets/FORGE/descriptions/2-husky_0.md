#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1210

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the limitSell to true and
minSell to zero in the setLimitSell function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1210|

```
if(recipient == uniswapV2Pair && // Swap Tokens to BNB (SELL)
       sender != address(this) &&
       sender != owner() &&
       !excludeFee[sender]){
       bool allowToSell = true;
       if(limitSell == true) {
         if(amount < minSell*10**18 || amount > maxSell*10**18) {
           allowToSell = false;
         }
       }
       if(allowToSell == true) {
         if(taxStatus == true){

```

##### Recommendation

The contract could embody a check for not allowing setting the variables less or
more than a reasonable amount. A suggested implementation could check that the
minimum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

