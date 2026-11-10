3) Unprotected Ether Withdrawal: L940 - 947;

 Ether and tokens are the basis of smart contracts on which the contract

 runs and executes transactions. Therefore, it is absolutely necessary to


-----

###### have input and access control validations on the functions executing

 funds withdrawal within the contract. The following unprotected public

 and external functions were found which were accepting addresses

 controlled by external users.

 Recommendation: 

 It is recommended to go through the functions and make sure that the

 ether withdrawal implements an access control, input validation, and/or

 that the funds of the user is depreciated after they withdraws the

 amount.

 