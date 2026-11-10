#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L584

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setFeeWallet function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L584|


function setFeeWallet(uint256 _liquidityFee, uint256 _projectFee) public onlyOwner

{

require(_liquidityFee >= 1, "Liquidity Fee be more than 1.");
require(_projectFee >= 5, "Project Fee be more than 5.");
liquidityFee = _liquidityFee;
projectFee = _projectFee;
}


##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

