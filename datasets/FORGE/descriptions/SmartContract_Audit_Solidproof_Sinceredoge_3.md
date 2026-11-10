#### Low issues


File Type Line Description

Main Contract doesn’t  - We recommend to import all
import npm packages packages from npm directly
from source (like without flatten the contract.
OpenZeppelin etc.) Functions could be modified

or can be susceptible to
vulnerabilities

Main A floating pragma is set 21 The current pragma Solidity

directive is „“^0.8.4””.

Main Missing Zero Address 134, 324, 331 Check that the address is not
Validation (missing- zero
zero-check)

Main Local variables 248, 227 Rename the local variables


22


-----

|#5|Main|Rename onlyDev modifei r|197|Rename the onlyDev modifei r because developmentAddress not the only one who can pass this modifei r. The owner can pass this modifier too. This could be irritate the investors while reading the contract code If you change it, make sure to change it everywhere else in the code|
|---|---|---|---|---|


#### Informational issues

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|Main|State variables that could be declared constant (constable- states)|111|Add the `constant` attributes to state variables that never change|
|#2|Main|Unused state variables|111, 145|Remove unused state variables|
|#3|Main|Excluding issue while changing dev/ marketing address|324-328, 331-335|If you change development-/ marketingAddress please make sure to include old development/marketing address in fees otherwise the old development address is excluded from fees|


investors while reading the
contract code

If you change it, make sure to
change it everywhere else in
the code

