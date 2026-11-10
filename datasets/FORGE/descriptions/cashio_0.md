#### Whitelist Addresses

**Criticality** high

**Location** https://bscscan.com/address/0x54ef94beb6f890860f6bcee78b16b58613034771#c
ode#L631

##### Description

The contract owner has the authority to whitelist addresses from the maximum
acceptable ticket amount. Also the contract owner has the ability set the
```
maxKeysPerTx to zero. That means that an excluded address can buy a huge

```
amount of tickets and always be the winner.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x54ef94beb6f890860f6bcee78b16b58613034771#c ode#L631|

```
require(noTicket <= maxKeysPerTx || maxKeysPerTxWhitelist[msg.sender], "Number
ticket must be less than maxAmount");

```

##### Recommendation

Since it is a game, there is no actual benefit for the game progress to have
whitelisted addresses. This functionality can be eliminated from the contract.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

