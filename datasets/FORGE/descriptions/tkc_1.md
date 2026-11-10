#### BC - Blacklists Addresses


#### Description


The contract owner has the authority to massively stop addresses from transactions. The


owner may take advantage of it by calling the `blackList` function.


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

⬤ ZD Zero Division Unresolved

⬤ CO Code Optimization Unresolved

⬤ PVC Price Volatility Concern Unresolved

⬤ RSML Redundant SafeMath Library Unresolved

⬤ IDI Immutable Declaration Improvement Unresolved

⬤ L04 Conformance to Solidity Naming Conventions Unresolved

⬤ L05 Unused State Variable Unresolved

⬤ L09 Dead Code Elimination Unresolved

⬤ L14 Uninitialized Variables in Local Scope Unresolved

⬤ L16 Validate Variable Setters Unresolved

⬤ L17 Usage of Solidity Assembly Unresolved

⬤ L22 Potential Locked Ether Unresolved

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|


-----

