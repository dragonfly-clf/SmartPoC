#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L677, 757

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by setting a high value to the
_minimumTokensBeforeSwap variable.

|Criticality|minor|
|---|---|
|Location|contract.sol#L677, 757|

```
function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
  _minimumTokensBeforeSwap = newLimit;
}

```
```
bool overMinimumTokenBalance = contractTokenBalance >=
_minimumTokensBeforeSwap;
       if (overMinimumTokenBalance && !inSwapAndLiquify &&
!isMarketPair[sender] && swapAndLiquifyEnabled)
       {
         if(swapAndLiquifyByLimitOnly)
           contractTokenBalance = _minimumTokensBeforeSwap;
         swapAndLiquify(contractTokenBalance);
       }

```

##### Recommendation

The contract could embody a check for the maximum amount of funds that can be
swapped. Since a huge amount may violate the token’s price.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

