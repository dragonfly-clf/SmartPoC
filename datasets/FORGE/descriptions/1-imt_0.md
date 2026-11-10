#### ST - Stop Transactions

**Criticality** minor

**Location** contract.sol#L586

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner can use this functionality only before the trade is open.

|Criticality|minor|
|---|---|
|Location|contract.sol#L586|


if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {

require(isTradingEnabled, "Trade is not open");
}


##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

