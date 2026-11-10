#### TSD - Total Supply Diversion

**Criticality** critical

**Location** contract.sol#L502

##### Description

The amount that is added to the total supply does not equal the amount that is
added to the balances. As a result, the sum of balances is diverse from the total
supply.

The burn amount is subtracted from total supply, but it is not subtracted from the
balance. As a result, the balance is going to be greater than total supply.

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

The sum of balances should always be equal to the total supply.


-----

