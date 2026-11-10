##### Stacking Contract - ST - Stop Transactions

**Criticality** high

**Location** https://www.bscscan.com/address/0x41B2BA88a0DE89886277d2e8C083884B6dF
2ea47#code#L152

###### Description

The contract owner has the authority to stop the stacking transactions for all users.
The owner may take advantage of it by calling the changeActiveStatus function.

|Criticality|high|
|---|---|
|Location|https://www.bscscan.com/address/0x41B2BA88a0DE89886277d2e8C083884B6dF 2ea47#code#L152|

```
function registerAndStake(uint _amount, address _referrer) external
onlyUnregistered() whenActive() {
  require(msg.sender != _referrer, "Cannot refer self");

```

###### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.