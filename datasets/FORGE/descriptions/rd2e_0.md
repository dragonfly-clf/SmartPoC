#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1050

##### Description

The contract owner has the authority to stop transactions or increase the fees for all
users excluding the owner. The owner may take advantage of it by setting a
malicious implementation to the antiBot address.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1050|

```
uint256 fee = antiBot.protect(sender, recipient, amount);
if (fee > 0) {
  super._transfer(sender, _addressFee, fee);
}

```

##### Recommendation

The contract should allow setting the antiBot address once and the address should
be verified so the investors will know the behaviour of this contract.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

