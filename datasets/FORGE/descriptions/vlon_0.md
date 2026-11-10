#### MT - Mint Tokens

**Criticality** critical

**Location** https://bscscan.com/address/0xc5419b49c60521116152fA47481b70CD8D0B74
2E#code#L588

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mint function. As a result the total supply will be
highly inflated.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0xc5419b49c60521116152fA47481b70CD8D0B74 2E#code#L588|

```
function mint(uint256 amount) public onlyOwner returns (bool) {
 _mint(_msgSender(), amount);
 return true;
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
renouncing ownership.