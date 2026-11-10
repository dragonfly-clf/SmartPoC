#### L18 - Multiple Pragma Directives

**Criticality** Minor / Informative

**Location** Guitarist.sol#L5,37,99,118,173,210,238,321,513,538,565,591,621,732,86
4,893,923,1551

**Status** Unresolved

#### Description

If the contract includes multiple conflicting pragma directives, it may produce unexpected

errors. To avoid this, it's important to include the correct pragma directive at the top of the

contract and to ensure that it is the only pragma directive included in the contract.
```
 pragma solidity ^0.8.0;
 pragma solidity ^0.8.13;
 pragma solidity ^0.8.4;

#### Recommendation

```
It is important to include only one pragma directive at the top of the contract and to ensure

that it accurately reflects the version of Solidity that the contract is written in.

By including all required compiler options and flags in a single pragma directive, the

potential conflicts could be avoided and ensure that the contract can be compiled correctly.


-----

