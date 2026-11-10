#### 5.1.6 Old pragma version
Severity: INFORMATIONAL
Status: ACKNOWLEDGED
File(s) affected: All

|hardcoded address and it's usage.|Col2|Col3|
|---|---|---|

|Attack / Description|Code Snippet|Result/Recommendation|
|---|---|---|
|Solidity contracts can use a special form of comments to provide rich documentation for functions, return variables and more. This special form is named the Ethereum Natural Language Specification Format (NatSpec).|Overall|It is recommended to include natspec documentation and follow the doxygen style including @author, @title, @notice, @dev, @param, @return and make it easier to review and understand your smart contract.|

|Attack / Description|Code Snippet|Result/Recommendation|
|---|---|---|
|Old pragma version can lead to errors|Line 1 pragma solidity ^0.5.13;|Use at least 0.6.12|