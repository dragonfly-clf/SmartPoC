## 31


-----

_totalSupply = _totalSupply.sub(amount);

emit Transfer(account, address(0), amount);

}

/**

- @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.


- This internal function is equivalent to `approve`, and can be used to

- e.g. set automatic allowances for certain subsystems, etc.


- Emits an {Approval} event.


- Requirements:


- - `owner` cannot be the zero address.

- - `spender` cannot be the zero address.

*/

function _approve(address owner, address spender, uint256 amount) internal {

require(owner != address(0), "ERC20: approve from the zero address");

**//SlowMist// This kind of check is very good, avoiding user mistake leading to**

**approve errors**

require(spender != address(0), "ERC20: approve to the zero address");

_allowances[owner][spender] = amount;

emit Approval(owner, spender, amount);

}

/**

- @dev Hook that is called before any transfer of tokens. This includes

- minting and burning.


- Calling conditions:


- - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens

- will be to transferred to `to`.

- - when `from` is zero, `amount` tokens will be minted for `to`.

- - when `to` is zero, `amount` of ``from``'s tokens will be burned.

- - `from` and `to` are never both zero.


- To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using
hooks[Using Hooks].

*/

function _beforeTokenTransfer(address from, address to, uint256 amount) internal {

require(!frozen(), "ERC20: token transfer while frozen");


