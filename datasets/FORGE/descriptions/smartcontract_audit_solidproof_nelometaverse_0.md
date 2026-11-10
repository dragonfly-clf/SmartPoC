#### Commented Code exist

###### There are some instances of code being commented out in the following files that should be removed:


23

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|Main|Contract doesn’t import npm packages from source (like OpenZeppelin etc.)|-|We recommend to import all packages from npm directly without flatten the contract. Functions could be modified or can be susceptible to vulnerabilities|
|#2|Main|A floating pragma is set|1174|The current pragma Solidity directive is „“^0.7.6””.|
|#3|Main|State variable visibility is not set|1225|It is best practice to set the visibility of state variables explicitly|
|#4|Main|Tautology or contradiction|1258, 1259, 1504, 1509, 1499|Fix the incorrect comparison by changing the value type or the comparison|


#### Critical issues

**- no critical issues found -**

#### High issues

**- no high issues found -**

#### Medium issues

**- no medium issues found -**

