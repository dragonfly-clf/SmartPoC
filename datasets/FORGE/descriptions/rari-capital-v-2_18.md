## QSP-19 Unlocked Pragma

#### Severity: Informational

 Status: Fixed

###### File(s) affected: All contracts


###### Description: Every Solidity file specifies in the header a version number of the format pragma solidity (^)0.5.*. The caret ( ) before the version number implies an unlocked pragma,^ meaning that the compiler will use the specified version and above, hence the term "unlocked."

 Recommendation: For consistency and to prevent unexpected behavior in the future, it is recommended to remove the caret to lock the file onto a specific Solidity version. Since the project uses external libraries, which together would only support at least version 0.5.9 of the Solidity compiler, the pragma should be locked at a version of solidity great or equal to 0.5.9.


