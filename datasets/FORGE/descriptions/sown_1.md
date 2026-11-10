#### BT - Burns Tokens


#### Description


The contract `Bnt` role has the authority to burn tokens from a specific address. The `Bnt`


role may take advantage of it by calling the `bntFromSown` function. As a result, the


targeted address will lose the corresponding tokens.


#### Recommendation


The team should carefully manage the private keys of the `Bnt` role account. It is crucial

that the Bnt role exercises utmost caution when interacting with the contract.


#### Team Update


The ownership has been transferred to the


`0x3d08b97608b73fa423d52489fd18a5c67d775270` contract and cannot be


changed. The team states that it’s a dual token protocol, the circulatory supply of Bnt


controls the circulatory supply of SOWN. Nobody can mint or burn not even the contract


owner. People can convert their Bnt to SOWN or SOWN to Bnt.


-----

### Diagnostics

⬤ Critical ⬤ Medium ⬤ Minor / Informative

**Severity** **Code** **Description** **Status**

⬤ RSML Redundant SafeMath Library Unresolved

⬤ RSK Redundant Storage Keyword Unresolved

⬤ IDI Immutable Declaration Improvement Unresolved

⬤ L02 State Variables could be Declared Constant Unresolved

⬤ L04 Conformance to Solidity Naming Conventions Unresolved

⬤ L06 Missing Events Access Control Unresolved

⬤ L07 Missing Events Arithmetic Unresolved

⬤ L09 Dead Code Elimination Unresolved

⬤ L13 Divide before Multiply Operation Unresolved

⬤ L16 Validate Variable Setters Unresolved

⬤ L17 Usage of Solidity Assembly Unresolved

⬤ L19 Stable Compiler Version Unresolved

⬤ L20 Succeeded Transfer Check Unresolved

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|


-----

