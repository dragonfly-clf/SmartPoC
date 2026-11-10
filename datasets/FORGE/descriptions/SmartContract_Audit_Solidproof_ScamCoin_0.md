#### Informational issues

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|Main|Contract doesn’t import npm packages from source (like OpenZeppelin etc.)|-|We recommend to import all packages from npm directly without flatten the contract. Functions could be modified or can be susceptible to vulnerabilities|
|#2|Main|A floating pragma is set|11|The current pragma Solidity directive is „“^0.8.7””.|
|#3|Main|Missing Zero Address Validation (missing- zero-check)|171, 474, 752,|Check that the address is not zero|
|#4|Main|State variable visibility is not set|722, 221, 255, 254, 256, 250, 251, 252, 242|It is best practice to set the visibility of state variables explicitly|
|#5|Main|Missing Events Arithmetic|289, 693, 702, 742, 757, 762, 719|Emit an event for critical parameter changes|

|Issue|File|Type|Line|Description|
|---|---|---|---|---|


#### Critical issues

**- no critical issues found -**

#### High issues

**- no high issues found -**

#### Medium issues

**- no medium issues found -**

