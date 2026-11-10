## 28


-----

*/

function decreaseAllowance(address spender, uint256 subtractedValue) public

notBlacklisted(_msgSender())

notBlacklisted(spender)

returns (bool)

{

_approve(_msgSender(), spender, _allowances[_msgSender()]

[spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));

return true;

}

/**

- @dev Issues `amount` tokens to the designated `address`.


- Can only be called by the current owner.

- See {ERC20-_mint}.

*/

**//SlowMist// The Minter role can mint tokens arbitrarily through the mint function**

**and there is no upper limit on the amount of tokens that can be minted**

function mint(address account, uint256 amount) public

onlyMinter

notBlacklisted(_msgSender())

notBlacklisted(account)

{

_mint(account, amount);

}

/**

- @dev Destroys `amount` tokens from the caller.


- See {ERC20-_burn}.

*/

function burn(uint256 amount) public

notBlacklisted(_msgSender())

{

_burn(_msgSender(), amount);

}

/**

- @dev Disable the {transfer}, {mint} and {burn} functions of contract.


- Can only be called by the current owner.

- The contract must not be frozen.

*/


