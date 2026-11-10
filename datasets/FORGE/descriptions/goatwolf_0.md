#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L558,561

##### Description

The contract owner has the authority to stop selling transactions for all users
including the owner. The owner may take advantage of it by setting the liquidityFee
and projectFee to values greater than the totalFee. As a result the methods
swapExactTokensForETHSupportingFeeOnTransferTokens will revert and turn the
contract into a honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L558,561|


function _transfer(

address from,
address to,
uint256 amount
) internal override {

require(from != address(0), "ERC20: transfer from the zero address");
require(to != address(0), "ERC20: transfer to the zero address");
if(amount == 0) {

super._transfer(from, to, 0);
return;
}
uint256 contractTokenBalance = balanceOf(address(this));

if( !swapping && contractTokenBalance > 0 && !automatedMarketMakerPairs[from])
{

swapping = true;

uint256 liquidityTokens = (contractTokenBalance * liquidityFee) / totalFee;
swapAndLiquidity(liquidityTokens);

uint256 projectTokens = (contractTokenBalance * projectFee) / totalFee;
swapAndSendMarketing(projectTokens);

swapping = false;
}


-----

##### Recommendation

The contract could embody a check for not allowing setting the liquidityFee and
projectFee to values greater than the totalFee.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

