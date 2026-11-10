#### OCTD - Owner Contract Tokens Drain

**Criticality** minor

**Location** contract.sol#L1518

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the sweepTokenForBosses function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1518|


function sweepTokenForBosses(uint256 tokenAmount)

external
onlyRole(SWEEPER_ROLE)
{

uint256 contractTokenBalance = balanceOf(address(this));
if (tokenAmount > contractTokenBalance) {

tokenAmount = contractTokenBalance;
}
if (tokenAmount >= tokenForBosses) {

_swapTokensForEth(tokenForBosses);
} else {

_swapTokensForEth(tokenAmount);
}
}


##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

