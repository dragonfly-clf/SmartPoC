## QSP-21 Checks-Effects-Interactions Pattern


-----

#### Severity: Informational

 Status: Fixed

###### File(s) affected: RariFundManager.sol


###### Description:


###### The Checks-Effects-Interactions coding pattern is meant to mitigate any chance of other contracts manipulating the state of the blockchain in unexpected and possibly malicious


###### ways before control is returned to the original contract. As the name implied, only after checking whether appropriate conditions are met and acting internally on those conditions should any

 external calls to, or interactions with, other contracts be done.

 Recommendation: This pattern is not followed in several places, for example on L752 within _withdrawFrom(), the token transfer should happen after setting the _netDeposits and
 _netDepositsByAccount to match this recommended pattern.


