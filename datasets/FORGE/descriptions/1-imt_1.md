#### OCTD - Owner Contract Tokens Drain

**Criticality** minor

**Location** contract.sol#L507

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the claimStuckTokens function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L507|


function claimStuckTokens(address token) external onlyOwner {

require(token != address(this), "Owner cannot claim native tokens");
if (token == address(0x0)) {

payable(msg.sender).transfer(address(this).balance);
return;
}
IERC20 ERC20token = IERC20(token);
uint256 balance = ERC20token.balanceOf(address(this));
ERC20token.transfer(msg.sender, balance);
}


##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

