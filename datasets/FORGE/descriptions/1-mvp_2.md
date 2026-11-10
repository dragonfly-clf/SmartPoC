#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L597, 674, 706

**Status** Resolved

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by setting a high fee to the
setNumTokensBeforeSwap variable.

|Criticality|minor|
|---|---|
|Location|contract.sol#L597, 674, 706|
|Status|Resolved|

```
function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
  minimumTokensBeforeSwap = newLimit;
}

```
```
uint256 contractTokenBalance = balanceOf(address(this));
       bool overMinimumTokenBalance = contractTokenBalance >=
minimumTokensBeforeSwap;

```
```
function swapAndLiquify(uint256 tAmount) private lockTheSwap {
    uint256 tokensForLP =
tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
    uint256 tokensForSwap = tAmount.sub(tokensForLP);
    swapTokensForEth(tokensForSwap);

```

##### Recommendation

The contract could embody a check for the maximum amount of funds that can be
swapped. Since a huge amount may volatile the token’s price.


-----

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

#### Updated 09 March 2022

The team has renounced ownership and resolved the issues.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|MC|Missing Check|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L05|Unused State Variable|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|
|⬤|L13|Divide before Multiply Operation|


-----

