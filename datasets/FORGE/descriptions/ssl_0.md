#### OCTD - Transfers Contract's Tokens

**Criticality** minor / informative

**Location** contract.sol#L321

**Status** Unresolved

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the methods clearStuckToken or
bulksend.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L321|
|Status|Unresolved|


**function clearStuckToken(address tokenAddress, uint256 tokens) external onlyOwner**
**returns (bool success) {**

**if(tokens == 0){**

**tokens = BEP20(tokenAddress).balanceOf(address(this));**
**}**

**return BEP20(tokenAddress).transfer(msg.sender, tokens);**
**}**


##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

