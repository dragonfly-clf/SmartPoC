#### L09 - Dead Code Elimination

**Criticality** Minor / Informative

**Location** BEP20Token.sol#L553,588

**Status** Unresolved

#### Description

In Solidity, dead code is code that is written in the contract, but is never executed or

reached during normal contract execution. Dead code can occur for a variety of reasons,

such as:

  - Conditional statements that are always false.

  - Functions that are never called.

  - Unreachable code (e.g., code that follows a return statement).

Dead code can make a contract more difficult to understand and maintain, and can also

increase the size of the contract and the cost of deploying and interacting with it.
```
 function _burn(address account, uint256 amount) internal {
   require(account != address(0), "BEP20: burn from the zero
 address");
   _balances[account] = _balances[account].sub(amount, "BEP20:
 burn amount exceeds balance");
   _totalSupply = _totalSupply.sub(amount);
   emit Transfer(account, address(0), amount);
  }
 function _burnFrom(address account, uint256 amount) internal {
   _burn(account, amount);
   _approve(account, _msgSender(),
 _allowances[account][_msgSender()].sub(amount, "BEP20: burn
 amount exceeds allowance"));
  }

#### Recommendation

```