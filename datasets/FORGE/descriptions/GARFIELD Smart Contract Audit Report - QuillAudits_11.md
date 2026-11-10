10. Loops in the Contract are extremely costly

 Description The for loops in the entire codebase includes state variables .length of a non-memory array, in the condition of the for loops. As a result, these state variables consume a lot more extra gas for every iteration of the for loop.

 Remediation We recommend using a local variable instead of a state variable .length in a loop for the entire codebase.

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit f5b0e4d88928ab05c42ed764bb09dec3d7a71fc5

#### 