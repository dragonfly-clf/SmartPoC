Important Information

v Active Owner: **0x2c2473fc2575717c34fd4b910be3884a55480600**

v **Be aware that active smart contract owner privileges constitute an elevated impact to**

**smart contract’s safety and security.**

v **The smart contract owner can mint the tokens increasing the total supply.**
```
 /** @dev Creates `amount` tokens and assigns them to `account`, increasing
  * the total supply.
  *
  * Emits a {Transfer} event with `from` set to the zero address.
  *
  * Requirements
  *
  * - `to` cannot be the zero address.
  */
 function _mint(address account, uint256 amount) internal {
  require(account != address(0), "BEP20: mint to the zero address");
  _totalSupply = _totalSupply.add(amount);
  _balances[account] = _balances[account].add(amount);
  emit Transfer(address(0), account, amount);
 }

```
v **The smart contract owner can burn the tokens decreasing the total supply.**
```
* @dev Destroys `amount` tokens from `account`, reducing the
  * total supply.
  *
  * Emits a {Transfer} event with `to` set to the zero address.
  *
  * Requirements
  * - `account` cannot be the zero address.
  * - `account` must have at least `amount` tokens.
  */
 function _burn(address account, uint256 amount) internal {
  require(account != address(0), "BEP20: burn from the zero address");
  _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
  _totalSupply = _totalSupply.sub(amount);
  emit Transfer(account, address(0), amount);
 }

```

**smart contract’s safety and security.**

v **The smart contract owner can mint the tokens increasing the total supply.**
```
 /** @dev Creates `amount` tokens and assigns them to `account`, increasing
  * the total supply.
  * Emits a {Transfer} event with `from` set to the zero address.
  * Requirements
  * - `to` cannot be the zero address.
function _mint(address account, uint256 amount) internal {
require(account != address(0), "BEP20: mint to the zero address");
  _totalSupply = _totalSupply.add(amount);
  _balances[account] = _balances[account].add(amount);
emit Transfer(address(0), account, amount);

```
v **The smart contract owner can burn the tokens decreasing the total supply.**
```
* @dev Destroys `amount` tokens from `account`, reducing the
  * total supply.
  * Emits a {Transfer} event with `to` set to the zero address.
  * Requirements
  * - `account` cannot be the zero address.
  * - `account` must have at least `amount` tokens.
function _burn(address account, uint256 amount) internal {

```

-----

v Owner can-not lock or burn user assets.

v Owner can-not stop or pause the smart contract.

v Kintaman Token’s smart contract utilizes “SafeMath” function to avoid common smart

contract vulnerabilities.
```
library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
  uint256 c = a + b;
  require(c >= a, 'SafeMath: addition overflow');
  return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
  return sub(a, b, 'SafeMath: subtraction overflow');
 }
 uint256 c = a * b;
  require(c / a == b, 'SafeMath: multiplication overflow');
  return c;
 }

```
v Kintaman Token’s smart contract has 1 low severity issue which may or may not create any

functional vulnerability.

{

"resource": " /Kintaman.sol",

"owner": "_generated_diagnostic_collection_name_#0",

**"severity": 8, (! Low Severity)**

**"** **Expected identifier, got 'LParen”,**

"source": "solc",

}

```
library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
  uint256 c = a + b;
  require(c >= a, 'SafeMath: addition overflow');
  return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
  return sub(a, b, 'SafeMath: subtraction overflow');
 }
 uint256 c = a * b;
  require(c / a == b, 'SafeMath: multiplication overflow');
  return c;
 }

```
v Kintaman Token’s smart contract has 1 low severity issue which may or may not create any

functional vulnerability.

{

"resource": " /Kintaman.sol",

"owner": "_generated_diagnostic_collection_name_#0",

**"severity": 8, (! Low Severity)**

**"** **Expected identifier, got 'LParen”,**


-----

# 