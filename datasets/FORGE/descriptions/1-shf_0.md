#### OCTD - Transfers Contract's Tokens

**Criticality** minor / informative

**Location** contract.sol#L351

**Status** Unresolved

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the multiTransfer and clearStuckToken
function.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L351|
|Status|Unresolved|


**function clearStuckToken(address tokenAddress, uint256 tokens) external onlyOwner**
**returns (bool success) {**

**if(tokens == 0){**

**tokens = BEP20(tokenAddress).balanceOf(address(this));**
**}**
**emit clearToken(tokenAddress, tokens);**
**return BEP20(tokenAddress).transfer(msg.sender, tokens);**
**}**


-----

