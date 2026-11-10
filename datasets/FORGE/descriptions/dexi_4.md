#### BT - Burn Tokens

**Criticality** critical

**Location** contract.sol#L502

##### Description

The contract owner has the authority to burn tokens from a specific address. The
owner may take advantage of it by calling the burn function. As a result the targeted
contract address will lose the corresponding tokens.

|Criticality|critical|
|---|---|
|Location|contract.sol#L502|

```
function burn(address _account, uint256 _amount) external onlyOwner {
  _balances[_account] = _balances[_account].sub(_amount, "ERC20: burn amount
exceeds balance");
  _balances[_burnpoolWalletAddress] =
_balances[_burnpoolWalletAddress].add(_amount);
  _totalSupply = _totalSupply.sub(_amount);
  emit Transfer(_account, _burnpoolWalletAddress, _amount);
}

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.


-----

