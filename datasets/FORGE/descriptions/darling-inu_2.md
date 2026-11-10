#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L873, 882

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by calling the process_Tokens_Now function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L873, 882|

```
  function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap
{
    swapTokensForBNB(contractTokenBalance);
    uint256 contractBNB = address(this).balance;
    sendToWallet(Wallet_Dev,contractBNB);
  }

```
```
  function process_Tokens_Now (uint256 percent_Of_Tokens_To_Process) public
onlyOwner {
    // Do not trigger if already in swap
    require(!inSwapAndLiquify, "Currently processing, try later.");
    if (percent_Of_Tokens_To_Process > 100){percent_Of_Tokens_To_Process
== 100;}
    uint256 tokensOnContract = balanceOf(address(this));
    uint256 sendTokens =
tokensOnContract*percent_Of_Tokens_To_Process/100;
    swapAndLiquify(sendTokens);
  }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

