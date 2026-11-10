#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L697

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the antiSandwichSeconds to
a high value. As a result the users that bought or sold once, will not be able to trade
again.

|Criticality|critical|
|---|---|
|Location|contract.sol#L697|

```
if (antiSandwich){
  uint secondsPassed = block.timestamp - lastTrade[msg.sender];
  require(secondsPassed >= antiSandwichSeconds, "AntiBot: You cant trade
yet.");
}

```

##### Recommendation

The contract could embody a check for not allowing setting the
antiSandwichSeconds more than a reasonable amount. A suggested
implementation could check that the maximum amount should be more than a fixed
percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|


-----

