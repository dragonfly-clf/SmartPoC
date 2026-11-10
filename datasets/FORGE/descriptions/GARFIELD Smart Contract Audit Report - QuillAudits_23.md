20. Incorrect versions of Solidity

 Solidity version used: 0.6.8.

 Description solc frequently releases new compiler versions. Using an old version prevents access to new Solidity security checks. We also recommend avoiding complex pragma statements.

 Remediation Deploy with any of the following Solidity versions:   0.5.16 - 0.5.17   0.6.11 - 0.6.12   0.7.5 - 0.7.6 

 Use a simple pragma version that allows any of these versions. Consider using the latest version of Solidity for testing.

 Status: Closed The Garfield team made some fixes based on our recommendations.

 0518


-----

###### 