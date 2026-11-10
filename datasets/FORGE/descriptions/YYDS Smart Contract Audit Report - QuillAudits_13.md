A.10: Functions guaranteed to revert can be marked payable

 Description

 Throughout the codebase, there are functions marked as onlyOwner. These functions are guaranteed to revert when a regular user tries to call them. To reduce the amount of gas other users would waste if they call the function, the functions can carry the payable function modifier.

 Remediation

 Make the functions payable to reduce the amount of gas spent on failed transactions.

 Status

 Acknowledged

 