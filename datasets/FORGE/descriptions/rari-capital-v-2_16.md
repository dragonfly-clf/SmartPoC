## QSP-17 Dangerous cast from uint256 to int256

#### Severity: Informational

 Status: Fixed

###### File(s) affected: RariFundManager.sol


###### Description: There is a cast to int256 on L515 in the RariFundManager, which would cause a large enough unsigned value to be converted to a negative value. However, this is highly unlikely to occur.

 Recommendation: Add an assertion statement to check if the uint256 is larger than the highest positive number that can be stored in int256, before the cast.

