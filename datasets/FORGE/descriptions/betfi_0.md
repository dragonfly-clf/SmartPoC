#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L917

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the sellTaxes to maximum
amount and the contract into a honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L917|


} else if(to == address(uniswapV2Pair)) {

tax += baseUnit * sellTaxes["marketing"];
tax += baseUnit * sellTaxes["dev"];
tax += baseUnit * sellTaxes["liquidity"];
tax += baseUnit * sellTaxes["charity"];

if(tax > 0) {

_transfer(from, address(this), tax);
}

marketingTokens += baseUnit * sellTaxes["marketing"];
devTokens += baseUnit * sellTaxes["dev"];
liquidityTokens += baseUnit * sellTaxes["liquidity"];
charityTokens += baseUnit * sellTaxes["charity"];


The contract owner has the authority to stop transactions including the owner by
calling the pause method.


function _transfer(

address sender,
address recipient,
uint256 amount
) internal override virtual {

require(!paused(), "CoinToken: token transfer while paused");


-----

##### Recommendation

The contract could embody a check for not allowing setting the sellTaxes to a
reasonable amount. A suggested implementation could check that the maximum
amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

