##### L17 - Usage of Solidity Assembly

|Criticality|Minor / Informative|
|---|---|
|Location|CryptoBitaxy.sol#L114,156|
|Status|Unresolved|


###### Description


Using assembly can be useful for optimizing code, but it can also be error-prone.
It's important to carefully test and debug assembly code to ensure that it is correct
and does not contain any errors.

Some common types of errors that can occur when using assembly in Solidity
include Syntax, Type, Out-of-bounds, Stack, and Revert.


###### Recommendation


It is recommended to use assembly sparingly and only when necessary, as it can be
difficult to read and understand compared to Solidity code.