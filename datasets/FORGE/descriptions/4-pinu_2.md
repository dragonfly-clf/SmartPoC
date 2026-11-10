#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L1350, 1354, 1358

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by calling the withdrawToken and withdrawBNB
functions.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1350, 1354, 1358|

```
function withdrawToken(address token) public onlyOwner {
  IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
}

```
```
function withdrawBNB() public onlyOwner {
  payable(msg.sender).transfer(address(this).balance);
}

```
```
function withdrawAmountBNB(uint256 amount) public onlyOwner {
  payable(msg.sender).transfer(amount);
}

```

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
|⬤|CO|Code Optimization|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|
|⬤|L14|Uninitialized Variables in Local Scope|


-----

