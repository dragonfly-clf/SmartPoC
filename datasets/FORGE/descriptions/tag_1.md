#### MT - Mint Tokens

**Criticality** medium

**Location** contract.sol#L1026

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mint function once every day. The function contains a
mint limitation to 2% of the total supply. Even that limitation, 2% of the total supply
is enough to highly inflated the token’s balance.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1026|

```
function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
  uint256 maxDaily = totalSupply() / 20;
  require(
    maxDaily > amount,
    "You can't mint that amount of tokens"
  );
  uint256 _now = block.timestamp;
  require(
    _now > lastMintDate + 24 hours,
    "Can't generate more tokens today, try again tomorrow"
  );
  lastMintDate = _now;
  _mint(to, amount);
}

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.


-----

