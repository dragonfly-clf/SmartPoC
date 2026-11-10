#### BT - Burn Tokens

**Criticality** critical

**Location** contract.sol#L742

**Status** Renounced Ownership

##### Description

The contract owner has the authority to burn tokens from a specific address without
checking for allowance of the user. The owner may take advantage of it by calling
the burn function. As a result the targeted contract address will lose the
corresponding tokens.

|Criticality|critical|
|---|---|
|Location|contract.sol#L742|
|Status|Renounced Ownership|

```
  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: burn from the zero address");
    _beforeTokenTransfer(account, address(0), amount);
    _balances[account] = _balances[account].sub(amount, "ERC20: burn amount
exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
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

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|


-----

