#### Informational

###### 4. Typo

 Description There is a typo in MINTABEL.

 Remediation We recommend correcting and changing MINTABEL to MINTABLE.

 Status: Open

 5. Incorrect versions of Solidity

 Solidity version used: 0.6.9.

 Description solc frequently releases new compiler versions. Using an old version prevents access to new Solidity security checks. We also recommend avoiding complex pragma statements.

 Remediation Deploy with any of the following Solidity versions:

 - 0.5.16 - 0.5.17
 - 0.6.11 - 0.6.12
 - 0.7.5 - 0.7.6

 Use a simple pragma version that allows any of these versions. Consider using the latest version of Solidity for testing.

 Status: Open

 6. State Variable Default Visibility

 L139: mapping(address => uint256) balances;

 Description The Visibility of the aforementioned variable is not defined. Labeling the visibility explicitly makes it easier to catch incorrect assumptions about who can access the variable.

 The default is internal for state variables, but it should be made explicit.

 Status: Open

 0507