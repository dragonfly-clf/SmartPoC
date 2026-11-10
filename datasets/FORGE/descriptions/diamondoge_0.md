#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L393

##### Description

The contract owner has the authority to transfer funds to the team wallet. These
funds have been accumulated from fees collected from the contract. The owner
may take advantage of it by calling the manualswap and manualsend sequencially.

|Criticality|minor|
|---|---|
|Location|contract.sol#L393|

```
function manualswap() external {
  require(_msgSender() == _developmentAddress || _msgSender() ==
_marketingAddress || _msgSender() == owner());
  uint256 contractBalance = balanceOf(address(this));
  swapTokensForEth(contractBalance);
}
function manualsend() external {
  require(_msgSender() == _developmentAddress || _msgSender() ==
_marketingAddress || _msgSender() == owner());
  uint256 contractETHBalance = address(this).balance;
  sendETHToFee(contractETHBalance);
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
|⬤|FSA|Fixed Swap Address|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L05|Unused State Variable|
|⬤|L04|Conformance to Solidity Naming Conventions|


-----

