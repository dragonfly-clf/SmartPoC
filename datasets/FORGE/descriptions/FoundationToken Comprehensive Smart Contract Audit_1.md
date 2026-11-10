1) Controlled low-level call: High-severity.  
 Status: Resolved. Line: #563

 The contract was using delegatecall() or call() which was accepting

 address controlled by a user. This can have devastating effects on the

 contract as a delegate call allows the contract to execute code belonging

 to other contracts but using it’s own storage. This can very easily lead to

 a loss of funds and compromise of the contract.

 Recommendation: 

 Do not allow user-controlled data inside the delegatecall() and the call()

 function. 

 