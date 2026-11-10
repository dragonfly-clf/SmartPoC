#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L1149

##### Description

The contract owner has the authority to transfer funds to the team wallet. These
funds have been swiped from the swap & liquify feature. From the accumulated
funds:

 - 1/7 is going to the auto generated liquidity pool.

 - 4/7 is going to the marketing wallet.

 - The rest is accumulated in the contract.

 - The buyback fee is 1% of the accumulated amount.

 - The contract owner has the ability to withdraw the remaining amount by
calling the withdrawBNB function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1149|

```
function withdrawBNB(uint256 amount) public onlyOwner() {
  if(amount == 0) payable(owner()).transfer(address(this).balance);
  else payable(owner()).transfer(amount);
}

```
```
function swapAndLiquify(uint256 tokenAmount) private lockSwapping {
  // Split the contract balance into the swap portion and the liquidity
portion
  uint256 eigth   = tokenAmount.div(8); // 1/8 of the tokens, used for
liquidity
  uint256 swapAmount = tokenAmount.sub(eigth); // 7/8 of the tokens, used to
swap for BNB
  // Capture the contract's current BNB balance so that we know exactly the
amount of BNB that the swap creates.
  // This way the liquidity event will not include any BNB that has been
collected by other means.

```

-----

```
  uint256 initialBalance = address(this).balance;
  // Swap 7/8ths of MMEW tokens for BNB
  swapTokensForBNB(swapAmount);
  // How much BNB did we just receive
  uint256 receivedBNB = address(this).balance.sub(initialBalance);
  // A seventh of the received BNB will be paired with the eigth of tokens
left behind
  uint256 liquidityBNB = receivedBNB.div(7);
  // Add liquidity via the PancakeSwap V2 Router
  addLiquidity(eigth, liquidityBNB);
  // We now have 6/7ths left of BNB (converted from MMEW)
  // We want to send 4/7ths to the marketing wallet and keep 2/7ths within the
contract for buyback
  uint256 marketingBNB = receivedBNB.div(7).mul(4);
  // Send the remaining BNB to the marketing wallet
  transferBNBToAddress(_marketingAddress, marketingBNB);
  emit SwapAndLiquify(swapAmount, liquidityBNB, eigth);
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
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L07|Missing Events Arithmetic|
|⬤|L15|Local Scope Variable Shadowing|
|⬤|L13|Divide before Multiply Operation|


-----

