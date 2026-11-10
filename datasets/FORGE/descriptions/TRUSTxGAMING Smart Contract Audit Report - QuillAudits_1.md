Medium Severity Issues

 A.2 Centralization Risk

 Description

 With the use of the Ownable contract inherited in the contract, it gives the contract owner privileges to call some functions. The contract owner can perform actions ranging from burning of tokens from any account, freezing an account which will deny freezed account from carrying out any token activities, pausing, and unpausing the token contract and also withdrawing any kind of token sent into the contract. Users must trust the contract owners to carry out these admin tasks.

 Remediation

 It is recommended that a trusted multisig address is used to perform admin duties.

 Status

 Acknowledged

 