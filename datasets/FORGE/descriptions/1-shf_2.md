#### ULTW - Transfers Liquidity to Team Wallet

**Criticality** minor / informative

**Location** contract.sol#L343

**Status** Unresolved

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by calling the clearStuckBalance methods.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L343|
|Status|Unresolved|


**function clearStuckBalance(uint256 amountPercentage) external onlyOwner {**

**require(amountPercentage < 101, "Max 100%");**
**uint256 amountBNB = address(this).balance;**
**uint256 amountToClear = ( amountBNB * amountPercentage ) / 100;**
**payable(msg.sender).transfer(amountToClear);**
**emit BalanceClear(amountToClear);**
**}**


##### Recommendation

The contract could embody a check for the maximum amount of funds that can be
swapped. Since a huge amount may volatile the token’s price.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|ZD|Zero Division|Unresolved|
|⬤|BM|Buyback Misleading|Unresolved|
|⬤|STC|Succeeded Transfer Check|Unresolved|
|⬤|FSA|Fixed Swap Address|Unresolved|
|⬤|L01|Public Function could be Declared External|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L13|Divide before Multiply Operation|Unresolved|


-----

