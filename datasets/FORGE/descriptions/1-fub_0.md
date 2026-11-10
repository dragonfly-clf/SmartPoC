#### OCTD - Owner Contract Tokens Drain

**Criticality** minor

**Location** contract.sol#L2175

**Status** Resolved

###### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the swapManual function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2175|
|Status|Resolved|


function swapManual() public onlyOwner {

uint256 contractTokenBalance = balanceOf(address(this));
require(contractTokenBalance > 0, "token balance zero");
swapping = true;
if(AmountLiquidityFee > 0) swapAndLiquify(AmountLiquidityFee);
if(AmountTokenRewardsFee > 0) swapAndSendDividends(AmountTokenRewardsFee);
if(AmountMarketingFee > 0) swapAndSendToFee(AmountMarketingFee);
swapping = false;
}


###### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

###### Updated 04 August 2022

The team has renounced ownership and resolved the issues.


-----

