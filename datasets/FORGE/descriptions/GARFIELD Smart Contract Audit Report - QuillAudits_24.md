21. Incorrect versions of Solidity

 Description It was discovered that the following code are commented in this contract: L918: // uint256 private _tTotal = 1000000000000000000000; L1063: // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Pancake router.');

 Unused code is allowed in Solidity, and they do not pose a direct security issue. It is best practice, though, to avoid them as they can:

   cause an increase in computations (and unnecessary gas    consumption)   indicate bugs or malformed data structures, and they are generally a     sign of poor code quality   cause code noise and decrease the readability of the code

 Remediation We recommend removing all unused variables/code from the codebase.

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 74a3184cc030cab1a0bfdc461d7d892e8c2bfc87

 