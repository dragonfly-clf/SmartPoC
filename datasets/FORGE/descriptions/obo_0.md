#### US - Untrusted Source

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|US|Untrusted Source|Unresolved|
|⬤|BLC|Business Logic Concern|Unresolved|
|⬤|CO|Code Optimization|Unresolved|
|⬤|L01|Public Function could be Declared External|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L03|Redundant Statements|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|
|⬤|L08|Tautology or Contradiction|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L15|Local Scope Variable Shadowing|Unresolved|


-----

|Criticality|critical|
|---|---|
|Location|contract.sol#L882,883,887|
|Status|Unresolved|


##### Description

The contract uses an external contract in order to determine the transaction's flow.
The external contract is untrusted. As a result it may produce security issues and
harm the transactions.


**if (**

**!isInPresale &&**
**transfer_to_profile_contract_address != address(0) &&**

**has_profile_transfers_enabled &&**
**ProfileTransferRouter(transfer_to_profile_contract_address).addressHasProfile(recipient)**
**&& ProfileTransferRouter(transfer_to_profile_contract_address).addressHasProfile(sender)**

**) {**

**if (has_external_profile_transfers) {**

**ProfileTransferRouter(transfer_to_profile_contract_address).transferToProfile(**

**sender,**
**recipient,**
**amount**
**);**


##### Recommendation

The contract should use a trusted external source. A trusted source could be either
a commonly recognized or an audited contract. The pointing addresses should not
be able to change after the initialization.

If the contract logic required an untrusted source, then the untrusted source should
be surrounded by a try-catch statement and it should not allow it to effect the
contract’s flow.


-----

