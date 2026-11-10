#### MT - Mint Tokens

**Criticality** critical

**Location** https://bscscan.com/address/0x205afd08cefe438377a0abc5a20cb4462e1a8c5c
#code#L300

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mint function. As a result the contract tokens will be
highly inflated and the team can abuse that to drain the liquidity and mass sell.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0x205afd08cefe438377a0abc5a20cb4462e1a8c5c #code#L300|

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
renouncing ownership.


-----

