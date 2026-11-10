#### ST - Stops Transactions

**Criticality** critical

**Location** contract.sol#L759,880

**Status** Unresolved

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the maxWalletToken to zero.

|Criticality|critical|
|---|---|
|Location|contract.sol#L759,880|
|Status|Unresolved|


**function setMaxWalletTokens(uint256 _maxToken) external onlyOwner {**

**maxWalletToken = _maxToken ;**
**}**

**…..**

**uint256 contractBalanceRecepient = balanceOf(to);**
**require(**

**contractBalanceRecepient + amount <= maxWalletToken,**
**"Exceeds maximum wallet token amount."**
**);**


##### Recommendation

The contract could embody a check for not allowing setting the maxWalletToken
less than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|RVO|Ratio Value Overflow|Unresolved|
|⬤|RSML|Redundant SafeMath Library|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|


-----

