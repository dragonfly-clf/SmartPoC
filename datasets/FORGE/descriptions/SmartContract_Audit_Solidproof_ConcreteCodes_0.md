#### Informational issues

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|Main|Contract doesn’t import npm packages from source (like OpenZeppelin etc.)|-|We recommend to import all packages from npm directly without flatten the contract. Functions could be modified or can be susceptible to vulnerabilities|
|#2|Main|A floating pragma is set|11|The current pragma Solidity directive is „“^0."".|
|#3|Main|Missing Zero Address Validation (missing- zero-check)|352|Check that the address is not zero|

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|Main|Functions that are not used|128|Remove unused functions|


