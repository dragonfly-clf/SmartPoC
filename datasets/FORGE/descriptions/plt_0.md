#### MT - Mint Tokens

**Criticality** critical

**Location** https://bscscan.com/address/0xd61b85636b4a5834c1e8a196da7218cebbf76c3
6#code#L256

**Resolved** The contract owner has renounced the ownership. Hence, the mint function
cannot be called.

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mint function. As a result the contract tokens will be
highly inflated.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0xd61b85636b4a5834c1e8a196da7218cebbf76c3 6#code#L256|
|Resolved|The contract owner has renounced the ownership. Hence, the mint function cannot be called.|

```
 function mint(address account, uint256 amount) onlyOwner public {
  totalSupply = totalSupply.add(amount);
  balances[account] = balances[account].add(amount);
  emit Mint(address(0), account, amount);
  emit Transfer(address(0), account, amount);
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

