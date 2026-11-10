#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** medium

**Location** contract.sol#L1

##### Description

The contract owner receives funds without limit to the team wallet. These funds
have been accumulated by the liquidity fee. When the accumulated amount reaches
the minimumTokensBeforeSwap value, then the tokens are liquidated and moved to
two addresses.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1|

```
function swapTokens(uint256 contractTokenBalance) private lockTheSwap {
  uint256 initialBalance = address(this).balance;
  swapTokensForEth(contractTokenBalance);
  uint256 transferredBalance = address(this).balance.sub(initialBalance);
  //Send to Marketing address
  transferToAddressETH(lp_poolAddress,
transferredBalance.div(_liquidityFee).mul(25));
  transferToAddressETH(marketingAddress,
transferredBalance.div(_liquidityFee).mul(marketingFee.sub(25)));
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L07|Missing Events Arithmetic|


-----

