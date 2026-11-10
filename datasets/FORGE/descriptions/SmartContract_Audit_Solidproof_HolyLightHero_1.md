## Audit Results


# AUDIT PASSED


#### Critical issues

 High issues

 Medium issues

 Low issues


Issue File Type

#1 Main Contract doesn’t
import npm packages
from source (like
OpenZeppelin etc.)

#2 Main Local variables
shadowing

#### Informational issues

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|Main|Contract doesn’t import npm packages from source (like OpenZeppelin etc.)|-|We recommend to import all packages from npm directly without flatten the contract. Functions could be modified or can be susceptible to vulnerabilities|
|#2|Main|Local variables shadowing|591, 428|Rename the local variables that shadow another component|

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|Main|Functions that are not used|605, 122, 221, 236, 256, 271, 196|Remove unused functions|


