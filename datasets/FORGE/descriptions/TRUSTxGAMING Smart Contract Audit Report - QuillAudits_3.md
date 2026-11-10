Informational Issues

 A.3 Double Frozen Account Require Check in the Approve Function

 Description

 There is a frozenAccount mapping in the contract used to identify accounts that have been frozen. This is however added in some functions to prevent the continuous activity of the frozen account. In the approve and _approve functions, there was a check that appears in both functions. The _approve internal function, this check was made likewise in the public approve function which will cause extra gas cost when the approve function is called by users.

 Remediation

 To save extra cost incurred when calling the approve function, remove a required check in one of the functions.

 Status

 Acknowledged

 A.4 Insufficient Code Comment and Specification

 Description

 There were some functions introduced into the token contract and sufficient code comments were not highlighted on them to explain why they were introduced. This also stretches to the smart contract specification provided before the start of the audit.

 Remediation

 Add more code comment on the additional functions in the contract and also a detailed specification proving data in the contract.

 Status

 Acknowledged

 B. General Recommendation

 With the admin task and privileges that the contract owner has, it is expected that users interacting with the token contract trust the contract owner. Hence, there should be a multisig account handling this admin task to mitigate the fear of the centralization risk.