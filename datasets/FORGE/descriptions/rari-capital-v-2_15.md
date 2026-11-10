## QSP-16 Fallback function can receive funds from any address

#### Severity: Informational


-----

#### Status: Fixed

###### File(s) affected: RariFundController.sol

 Description: The fallback function is meant to only be “called by 0x exchange to refund unspent protocol fee.” However, there are no restrictions/checks in place to guarantee this. This means
 that anyone could send funds to this contract by mistake.

 Recommendation: Add a requirement inside the fallback function to check if the msg.sender address belongs to 0x. This way the function will revert if any other address sends funds to it.

