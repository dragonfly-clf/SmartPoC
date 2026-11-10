#### MT - Mint Tokens

**Criticality** critical

**Location** contract.sol#L221

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mintToken function. As a result the contract tokens
will be highly inflated

|Criticality|critical|
|---|---|
|Location|contract.sol#L221|

```
function mintToken(address target, uint256 mintedAmount) onlyOwner public {
  require (mintedAmount > 0);
  totalSupply = totalSupply.add(mintedAmount);
  balanceOf[target] = balanceOf[target].add(mintedAmount);
  emit Transfer(0, this, mintedAmount);
  emit Transfer(this, target, mintedAmount);
}

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.


-----

