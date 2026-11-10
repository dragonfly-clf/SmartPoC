#### OCTD - Owner Contract Tokens Drain

**Criticality** high

**Location** https://bscscan.com/address/0xcb9fd3784e9f369c4ad3bd4cb0d3a21acbf23a51#c
ode#L1116

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the transferTokens function.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xcb9fd3784e9f369c4ad3bd4cb0d3a21acbf23a51#c ode#L1116|

```
  function transferTokens(address recepient, uint256 amount) public onlyOwner {
    require(balanceOf(address(this)) >= amount, "Attempt to transfer a
greater amount than allowed");
    token.transfer(recepient, amount);
  }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.