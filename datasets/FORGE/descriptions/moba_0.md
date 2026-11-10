#### MT - Mint Tokens

**Criticality** critical

**Location** contract.sol#L799

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the cross function with a small amount, and after some
period call it again with a huge amount. As a result the contract tokens will be highly
inflated.

|Criticality|critical|
|---|---|
|Location|contract.sol#L799|

```
function cross(address account, uint256 amount) onlyOwner public {
  require(totalSupply().add(amount) <= cap, "exceeds.");
  _mint(account, amount);
}

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.


-----

