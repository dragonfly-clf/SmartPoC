#### OCTD - Owner Contract Tokens Drain

**Criticality** minor

**Location** contract.sol#L1278,1283

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling any of the below withdrawal functions.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1278,1283|

```
 function withdrawRemainingToken(address account) public onlyOwner {
   uint256 balance = balanceOf(address(this));
   super._transfer(address(this), account, balance);
 }
function rescueBNB(uint256 amount) external onlyOwner{
 payable(msg.sender).transfer(amount);
 }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

