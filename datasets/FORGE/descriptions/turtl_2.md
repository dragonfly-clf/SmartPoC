#### BC - Blacklists Addresses


#### Description


The contract owner has the authority to massively stop addresses from transactions. The


owner may take advantage of it by calling the `setIsBlacklisted` function.


#### Recommendation


The team should carefully manage the private keys of the owner’s account. We strongly


recommend a powerful security mechanism that will prevent a single user from accessing


the contract admin functions. Some suggestions are:



- Introduce a time-locker mechanism with a reasonable delay.

- Introduce a multi-sign wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.

- Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

### Diagnostics

⬤ Critical ⬤ Medium ⬤ Minor / Informative

**Severity** **Code** **Description** **Status**

⬤ RMO Redundant Mint Override Unresolved

⬤ RSML Redundant SafeMath Library Unresolved

⬤ RSK Redundant Storage Keyword Unresolved

⬤ L02 State Variables could be Declared Constant Unresolved

⬤ L04 Conformance to Solidity Naming Conventions Unresolved

⬤ L05 Unused State Variable Unresolved

⬤ L07 Missing Events Arithmetic Unresolved

⬤ L09 Dead Code Elimination Unresolved

⬤ L13 Divide before Multiply Operation Unresolved

⬤ L15 Local Scope Variable Shadowing Unresolved

⬤ L16 Validate Variable Setters Unresolved

⬤ L17 Usage of Solidity Assembly Unresolved

⬤ L18 Multiple Pragma Directives Unresolved

⬤ L19 Stable Compiler Version Unresolved

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|


-----

