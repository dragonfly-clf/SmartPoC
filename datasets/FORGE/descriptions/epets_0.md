#### OCTD - Owner Contract Tokens Drain

**Criticality** minor

**Location** contract.sol#L335,340

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the clearStuckBalance function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L335,340|

```
  function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
    uint256 amountBNB = address(this).balance;
    payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
  }
  function clearStuckToken(address tokenAddress, uint256 tokens) public
onlyOwner returns (bool success) {
    if(tokens == 0){
       tokens = IBEP20(tokenAddress).balanceOf(address(this));
    }
    return IBEP20(tokenAddress).transfer(msg.sender, tokens);
  }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

