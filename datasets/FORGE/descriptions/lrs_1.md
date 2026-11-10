#### ULTW - Transfers Liquidity to Team Wallet

**Criticality** minor / informative

**Location** contract.sol#L387

**Status** Unresolved

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by calling the manualsend method.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L387|
|Status|Unresolved|

```
function manualsend() external {
  require(_msgSender() == _developmentAddress || _msgSender() ==
_marketingAddress || _msgSender() == owner());
  uint256 contractETHBalance = address(this).balance;
  sendETHToFee(contractETHBalance);
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

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|PTRP|Potential Transfer Revert Propagation|Unresolved|
|⬤|DDP|Decimal Division Precision|Unresolved|
|⬤|RSML|Redundant SafeMath Library|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|


-----

