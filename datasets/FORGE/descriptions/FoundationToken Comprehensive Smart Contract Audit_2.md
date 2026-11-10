2) Unchecked Transfer: High-severity. 

 Status: Acknowledged

 Line: #478, #484

 Some tokens do not revert the transaction when the transfer or

 transferFrom fails and returns False. Hence we must check the return

 value after calling the transfer or transferFrom function.

 Recommendation: 

 Use OpenZeppelin SafeERC20's safetransfer and safetransferFrom

 functions. 


-----

###### 