#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** medium

**Location** contract.sol#L307

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees into the contract balance.
The owner may take advantage of it by setting a high fee to the marketingWallet
variable and then calling distribute.

|Criticality|medium|
|---|---|
|Location|contract.sol#L307|

```
 function distribute() public onlyOwner swapping {
  require(stakingrewardPercentage + marketingPercentage +
buybackandburnPercentage == maxPercent, "The sum of percentage isn't 100.");
  require(
   stakingrewardWallet != address(0)
   && marketingWallet != address(0)
   && buybackandburnWallet != address(0)
  ,
   "Cannot send to zero wallet."
  );
  uint256 amount = getBalance();
  (bool sent_1, ) = payable(stakingrewardWallet).call{value: (amount *
stakingrewardPercentage / maxPercent), gas: 30000}(""); require(sent_1,
"Transfer wallet_1 error."); balance = address(this).balance;
  (bool sent_2, ) = payable(marketingWallet).call{value: (amount *
marketingPercentage / maxPercent), gas: 30000}(""); require(sent_2, "Transfer
wallet_2 error."); balance = address(this).balance;
  (bool sent_3, ) = payable(buybackandburnWallet).call{value: (amount *
buybackandburnPercentage / maxPercent), gas: 30000}(""); require(sent_3,
"Transfer wallet_3 error."); balance = address(this).balance;
 }

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

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
|⬤|L07|Missing Events Arithmetic|


-----

