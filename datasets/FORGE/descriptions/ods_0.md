#### ST - Stops Transactions


#### Description


Initially, the contract does not allow the non-excluded addresses to transfer tokens. The


restriction can be resumed once the contract owner enables them.


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

⬤ TSD Total Supply Diversion Unresolved

⬤ RCS Redundant Code Segment Unresolved

⬤ ZD Zero Division Unresolved

⬤ LED Lacking Event Details Unresolved

⬤ ISA Inaccurate Swap Amount Unresolved

⬤ AOI Arithmetic Operations Inconsistency Unresolved

⬤ TUU Time Units Usage Unresolved

⬤ RED Redundant Event Declaration Unresolved

⬤ PVC Price Volatility Concern Unresolved

⬤ DDP Decimal Division Precision Unresolved

⬤ RVD Redundant Variable Declaration Unresolved

⬤ MAL Misused Algorithmic Logic Unresolved

⬤ MC Missing Check Unresolved

⬤ RS Redundant Swaps Unresolved

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|


-----

⬤ RSML Redundant SafeMath Library Unresolved

⬤ RSK Redundant Storage Keyword Unresolved

⬤ L02 State Variables could be Declared Constant Unresolved

⬤ L04 Conformance to Solidity Naming Conventions Unresolved

⬤ L05 Unused State Variable Unresolved

⬤ L07 Missing Events Arithmetic Unresolved

⬤ L09 Dead Code Elimination Unresolved

⬤ L12 Using Variables before Declaration Unresolved

⬤ L13 Divide before Multiply Operation Unresolved

⬤ L14 Uninitialized Variables in Local Scope Unresolved

⬤ L15 Local Scope Variable Shadowing Unresolved

⬤ L16 Validate Variable Setters Unresolved

⬤ L19 Stable Compiler Version Unresolved

⬤ L20 Succeeded Transfer Check Unresolved


-----

