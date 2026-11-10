#### Medium severity issues

###### 4. Improper error handling

 Description Across the codebase, appropriate conditions are checked, but error messages are not being emitted, so if a transaction is reverted, the user will not know the reason for the failure.

 Remediation Properly analyze all pre and post conditions in which a transaction could fail and check them explicitly with appropriate error messages.

 Status: Open

 5. Owner cannot be transferred

 Description The contract owner is immutable - it cannot be transferred. This is a bad practice; in case of possible key leakage, the administration of the contract will be sabotaged too.

 Remediation Implement the functionality to transfer the ownership to a new user.

 Status: Open

