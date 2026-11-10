#### ULTW - Transfers Liquidity to Team Wallet

**Criticality** minor / informative

**Location** contract.sol#L1012

**Status** Unresolved

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by calling the manualDistributeBuyFee method.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1012|
|Status|Unresolved|


function manualDistributeBuyFee() public onlyOwner returns (bool) {

swapping = true;
**_swapBackToBUSD(balanceOf(address(this)));**
swapping = false;
Fees memory fees = _sellFeesByTime(block.timestamp);
**distributeRewardBUSD(fees);**
return true;
}


##### Recommendation

The contract could embody a check for the maximum amount of funds that can be
swapped. Since a huge amount may volatile the token’s price.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

