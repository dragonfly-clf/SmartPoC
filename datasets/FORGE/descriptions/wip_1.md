#### OCTD - Owner Contract Tokens Drain

**Criticality** high

**Location** https://bscscan.com/address/0x8d37cA3285a93e7E2bD50747a57c87EBf738c395#
code#L874,L879

##### Description

The contract owner has the authority to claim all the balance from any contract. The
owner may take advantage of it by calling the transferAnyERC20Tokens or
```
TransferETH function.

```
|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x8d37cA3285a93e7E2bD50747a57c87EBf738c395# code#L874,L879|

```
function transferAnyERC20Tokens(address _tokenAddress, address _to, uint256
_amount) public onlyOwner {
  Token(_tokenAddress).transfer(_to, _amount);
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

