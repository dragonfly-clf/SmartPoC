#### BC - Blacklists Addresses


#### Description


The contract’s authorized users have the authority to stop addresses from transactions. The


owner may take advantage of it by calling the `devListAddress` function.


#### Recommendation


The team should carefully manage the private keys of the owner’s account. We strongly


recommend a powerful security mechanism that will prevent a single user from accessing


the contract admin functions. Some suggestions are:



- Introduce a time-locker mechanism with a reasonable delay.

- Introduce a multi-sign wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.

- Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

15

### Diagnostics

⬤ Critical ⬤ Medium ⬤ Minor / Informative

**Severity** **Code** **Description** **Status**

⬤ ZD Zero Division Unresolved

⬤ PVC Price Volatility Concern Unresolved

⬤ MRM Missing Revert Messages Unresolved

⬤ DDP Decimal Division Precision Unresolved

⬤ RSK Redundant Storage Keyword Unresolved

⬤ IDI Immutable Declaration Improvement Unresolved

⬤ L02 State Variables could be Declared Constant Unresolved

⬤ L04 Conformance to Solidity Naming Conventions Unresolved

⬤ L07 Missing Events Arithmetic Unresolved

⬤ L16 Validate Variable Setters Unresolved

⬤ L19 Stable Compiler Version Unresolved

⬤ L20 Succeeded Transfer Check Unresolved

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|


-----

16


