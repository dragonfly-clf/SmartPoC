#### ST - Stops Transactions

**Criticality** minor / informative

**Location** contract.sol#L1199,1239

**Status** Unresolved

##### Description

The contract owner has the authority to stop the transactions for all users excluding
the owner. There is a chance after token launch that this check is true and the user
will get blacklisted. As a result the next time he tries to make a transaction it will fail.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1199,1239|
|Status|Unresolved|

```
if (launchBlock + killNum > block.number) addBot(to);

```

TotalTax is fixed to 5, but BurnFee can have values higher than 5. As a result the
transfer will revert.

```
uint256 denominator = (TotalTax.sub(BurnFee).sub(ReflectionFee)).mul(2);

```

##### Recommendation

The contract should remove the check that adds address to blacklist. The contract
should check first if BurnFee is greater than 5.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

