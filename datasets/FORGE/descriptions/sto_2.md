#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L540, 480, 567, 571

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by setting a high fee to the swapThreshold
variable.

|Criticality|minor|
|---|---|
|Location|contract.sol#L540, 480, 567, 571|

```
function setSwapThreshold(uint256 new_amount) external onlyOwner {
  swapThreshold = new_amount;
}

```
```
function swapForFees() private inSwap {
uint256 contractBalance = balanceOf(address(this));
if (contractBalance >= swapThreshold) {

```

The contract can also transfer funds by calling the rescueBEP20 and rescueBNB
functions.

```
function rescueBEP20(address tokenAddress, uint256 amount) external onlyOwner{
  IERC20(tokenAddress).transfer(owner(), amount);
}

```
```
function rescueBNB(uint256 weiAmount) external onlyOwner{
    payable(owner()).sendValue(weiAmount);
  }

```

-----

##### Recommendation

The contract could embody a check for the maximum amount of funds that can be
swapped. Since a huge amount may volatile the token’s price.

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
|⬤|MC|Missing Check|
|⬤|L01|Public Function could be Declared External|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|
|⬤|L13|Divide before Multiply Operation|
|⬤|L15|Local Scope Variable Shadowing|


-----

