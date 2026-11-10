## 30


-----

_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds

balance");

_balances[recipient] = _balances[recipient].add(amount);

emit Transfer(sender, recipient, amount);

}

/** @dev Creates `amount` tokens and assigns them to `account`, increasing

- the total supply.


- Emits a {Transfer} event with `from` set to the zero address.


- Requirements:


- - `to` cannot be the zero address.

*/

function _mint(address account, uint256 amount) internal {

require(account != address(0), "ERC20: mint to the zero address");

_beforeTokenTransfer(address(0), account, amount);

_totalSupply = _totalSupply.add(amount);

_balances[account] = _balances[account].add(amount);

emit Transfer(address(0), account, amount);

}

/**

- @dev Destroys `amount` tokens from `account`, reducing the

- total supply.


- Emits a {Transfer} event with `to` set to the zero address.


- Requirements:


- - `account` cannot be the zero address.

- - `account` must have at least `amount` tokens.

*/

function _burn(address account, uint256 amount) internal {

require(account != address(0), "ERC20: burn from the zero address");

_beforeTokenTransfer(account, address(0), amount);

_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds

balance");


