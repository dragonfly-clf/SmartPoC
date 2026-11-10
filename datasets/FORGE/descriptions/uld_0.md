#### ST - Stop Transactions

**Criticality** medium

**Location** contract.sol#L1015

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1015|


function _transfer(

address from,
address to,
uint256 amount
) private {

require(from != address(0), "ERC20: transfer from the zero address");
require(to != address(0), "ERC20: transfer to the zero address");
require(amount > 0, "Transfer amount must be greater than zero");
if(from != owner() && to != owner())

require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");


##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

