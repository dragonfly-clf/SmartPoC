##### ST - Stop Transactions

**Criticality** high

**Location** https://www.bscscan.com/address/0x4D5f45C030627c9CA6D555119A0a1Ed290A
B1140#code#L122

###### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by calling the pause function from the
Pausable class

|Criticality|high|
|---|---|
|Location|https://www.bscscan.com/address/0x4D5f45C030627c9CA6D555119A0a1Ed290A B1140#code#L122|

```
function transfer(address to, uint value) external returns(bool) {
    require(paused() == false || msg.sender == owner, 'Cannot transfer
paused token');

```

###### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

