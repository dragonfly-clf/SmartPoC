#### BT - Burn Tokens

**Criticality** critical

**Location** contract.sol#L850

**Status** Resolved

##### Description

The contract owner has the authority to decrease the total supply without limit. The
owner may take advantage of it by calling the burn function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L850|
|Status|Resolved|

```
function _burn(address account, uint256 amount) public virtual onlyOwner{
  require(account != address(0), "ERC20: burn from the zero address");
  // _beforeTokenTransfer(account, address(0), amount);
    _tTotal -= amount;
  // require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
  //_balances[account] = accountBalance - amount;
  // _totalSupply -= amount;
}

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.

##### Updated 10 May 2022

The team has renounced ownership and resolved the issues.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|


-----

