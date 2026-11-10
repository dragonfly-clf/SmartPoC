#### Medium severity issues

###### 4. Improper error handling

 Description Across the codebase, appropriate conditions are not checked, i.e., the balance of the user. If the user tries to transfer more tokens than he has, his transactions will simply fail due to solidity internal assertion of arithmetic overflow/underflow with unexpected revert message. This is consistent throughout the codebase among other functionalities as well, i.e., approve operations, etc. It’s good to check for cases in which a transaction could fail and have them revert if it can be failed further down the execution.

 Remediation Properly analyze all pre and post conditions in which a transaction could fail and check them explicitly with appropriate error messages.

 Status: Open

