#### Informational issues

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|Main|Contract doesn’t import npm packages from source (like OpenZeppelin etc.)|-|We recommend to import all packages from npm directly without flatten the contract. Functions could be modified or can be susceptible to vulnerabilities|
|#2|Main|A floating pragma is set|21|The current pragma Solidity directive is „“^0.”8.4”.|
|#3|Main|Missing Zero Address Validation (missing- zero-check)|322, 329132|Check that the address is not zero|
|#4|Main|Local variables shadowing|246, 225|Rename the local variables that shadow another component|

|Issue|File|Type|Line|Description|
|---|---|---|---|---|


