### L19 - Stable Compiler Version

**Criticality** Minor / Informative

**Location** TRITON.sol#L7

**Status** Unresolved

### Description

The `^` symbol indicates that any version of Solidity that is compatible with the specified

version (i.e., any version that is a higher minor or patch version) can be used to compile the

contract. The version lock is a mechanism that allows the author to specify a minimum

version of the Solidity compiler that must be used to compile the contract code. This is

useful because it ensures that the contract will be compiled using a version of the compiler

that is known to be compatible with the code.
```
 pragma solidity ^0.8.19;

### Recommendation

```
The team is advised to lock the pragma to ensure the stability of the codebase. The locked

pragma version ensures that the contract will not be deployed with an unexpected version.

An unexpected version may produce vulnerabilities and undiscovered bugs. The compiler

should be configured to the lowest version that provides all the required functionality for the

codebase. As a result, the project will be compiled in a well-tested LTS (Long Term Support)

environment.


-----

