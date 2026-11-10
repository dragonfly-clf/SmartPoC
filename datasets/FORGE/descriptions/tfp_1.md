##### OCTD - Owner Contract Tokens Drain

**Criticality** high

**Location** https://bscscan.com/address/0xb6b0f5dd8b12cf7f4a3ebe7e3e6e97b56b02d0ad#c
ode#L964

###### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the claimTokens function.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xb6b0f5dd8b12cf7f4a3ebe7e3e6e97b56b02d0ad#c ode#L964|

```
function claimTokens() public onlyOwner {
  payable(_owner).transfer(address(this).balance);
 }

```

###### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

