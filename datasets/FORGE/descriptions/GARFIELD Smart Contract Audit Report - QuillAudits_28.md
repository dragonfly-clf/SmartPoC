25. State Variable Default Visibility

 Line Code

 uint256 minTokenNumberToSell 1309

 Description The Visibility of the above-mentioned variable is not defined. Labeling the visibility explicitly makes it easier to catch incorrect assumptions about who can access the variable.

 The default is internal for state variables, but it should be made explicit.

 Remediation We recommend adding .visibility for these variables. Variables can be specified as being public, internal, or private. Explicitly define visibility for all state variables.

 Status: Closed The Garfield team made some fixes based on our recommendations.

 