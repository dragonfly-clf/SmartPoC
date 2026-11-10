#### Low issues


File Type Line Description

Main Contract doesn’t  - We recommend to import all
import npm packages packages from npm directly
from source (like without flatten the contract.
OpenZeppelin etc.) Functions could be modified

or can be susceptible to
vulnerabilities

Main A floating pragma is set 11 The current pragma Solidity

directive is „“^0.8.7””.

Main Missing Zero Address 171, 474, 752, Check that the address is not
Validation (missing- zero
zero-check)

Main State variable visibility 722, 221, 255, It is best practice to set the
is not set 254, 256, visibility of state variables

250, 251, 252, explicitly

242

Main Missing Events 289, 693, Emit an event for critical
Arithmetic 702, 742, parameter changes


###### 24


-----

|#1|Main|State variables that could be declared constant (constable- states)|251, 264, 411, 413, 415, 414, 421|Add the `constant` attributes to state variables that never change|
|---|---|---|---|---|
|#2|Main|Costly operations in a loop|351|Use a local variable to hold the loop computation result|
|#3|Main|Functions that are not used|709|Remove unused functions|
|#4|Main|Unused state variables|411, 415|Remove unused state variables|


#### Audit Comments

##### 26. January 2022:

###### • If the owner transfer the ownership the old owner is still authorized

 • Make sure to unauthorised old owner

 • Read whole report for more information


used

Main Unused state variables 411, 415 Remove unused state

variables

#### Audit Comments

##### 26. January 2022:

###### If the owner transfer the ownership the old owner is still authorized

 • Make sure to unauthorised old owner
 Read whole report for more information


###### 25


-----

