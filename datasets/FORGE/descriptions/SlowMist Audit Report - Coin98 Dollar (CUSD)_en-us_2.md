## 29


-----

function freeze() public onlyOwner {

_freeze();

}

/**

- @dev Enable the {transfer}, {mint} and {burn} functions of contract.


- Can only be called by the current owner.

- The contract must be frozen.

*/

function unfreeze() public onlyOwner {

_unfreeze();

}

/**

- @dev Set new minter

*/

function setMinter(address newMinter) public onlyOwner {

address oldMinter = _minter;

_minter = newMinter;

emit MinterUpdated(oldMinter, newMinter);

}

/**

- @dev Moves tokens `amount` from `sender` to `recipient`.


- This is internal function is equivalent to {transfer}, and can be used to

- e.g. implement automatic token fees, slashing mechanisms, etc.


- Emits a {Transfer} event.


- Requirements:


- - `sender` cannot be the zero address.

- - `recipient` cannot be the zero address.

- - `sender` must have a balance of at least `amount`.

*/

function _transfer(address sender, address recipient, uint256 amount) internal {

require(sender != address(0), "ERC20: transfer from the zero address");

**//SlowMist// This kind of check is very good, avoiding user mistake leading to**

**the loss of token during transfer**

require(recipient != address(0), "ERC20: transfer to the zero address");

_beforeTokenTransfer(sender, recipient, amount);


