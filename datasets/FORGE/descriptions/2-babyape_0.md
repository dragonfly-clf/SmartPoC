#### MT - Mint Tokens

**Criticality** critical

**Location** contract.sol#L851

**Status** Renounced Ownership

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mint function. As a result the contract tokens will be
highly inflated

|Criticality|critical|
|---|---|
|Location|contract.sol#L851|
|Status|Renounced Ownership|

```
function mint(address _to, uint256 _amount) public onlyOwner {
  _mint(_to, _amount);
  _moveDelegates(address(0), _delegates[_to], _amount);
}

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.

##### Update 21 April

The contract owner has renounced the ownership. As a result the threat has been
eliminated.


-----

