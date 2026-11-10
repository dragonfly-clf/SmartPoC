High Severity Issues

 1. Centralization Risk

 Description

 The contract is heavily centralized, and any compromise of the owner (responsible for the transactions carried out with the onlyOwner modifier) could lead to bricking the contract or a loss of funds.

 Remediation

 Client can implement a multi-signature wallet architecture making the risk of failure to as minimal as possible with more members of the multisig.

 DexterLabs Team Comment: As we did before, once the launch is completed we will move the ownership to a gnosis multisig safe to ensure the contracts safety.

 Status

 Resolved

 