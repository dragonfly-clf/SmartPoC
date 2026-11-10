3) Return Value of low-level calls: Medium-severity.  

 Lines: #557, #563

 Status: Acknowledged

 The functions do not check the return value of low-level calls. This can

 lock Ether in the contract if the call fails or may compromise the contract

 if the ownership is being changed. The following calls were detected

 without return value validations - call

 Recommendation: 

 Ensure return value is checked using conditional statements for low-level

 calls. We should also ensure that we log failed calls using events.