#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L1

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been swapped from the swap & liquify feature. The owner
may take advantage of it by:

1. Disable the liquifyEnabled

2. Disable the buyBackEnabled

3. When the contract has accumulated many funds, call the withdraw()

|Criticality|minor|
|---|---|
|Location|contract.sol#L1|

```
if (liquifyEnabled && amountToLiquify > 0) {
  swapAndLiquify(amountToLiquify, false);
}
// swap for buyback later
uint256 rest = contractTokenBalance.sub(amountToLiquify);
uint256 buyBack = rest.mul(buyBackFee).div(marketingFee+buyBackFee);
swapTokensForEth(buyBack);

```
```
function withdraw (address payable to, uint256 amount) public onlyOwner() {
  transferToAddressETH(to, amount);
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
|⬤|L02|State Variables could be Declared Constant|
|⬤|L05|Unused State Variable|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L11|Unnecessary Boolean equality|
|⬤|L07|Missing Events Arithmetic|


-----

