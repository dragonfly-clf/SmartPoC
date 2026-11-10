#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1352

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the extraSellFee to a high
number.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1352|

```
uint256 fees = amount * totalFees / 100;
if(automatedMarketMakerPairs[to]){
  fees += amount * extraSellFee / 100;
}
amount = amount - (fees);
super._transfer(from, address(this), fees);

```

##### Recommendation

The contract could embody a check for not allowing setting the total fees more than
25%. A suggested implementation could check that the maximum amount should
be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

