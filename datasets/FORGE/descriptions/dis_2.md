#### L18 - Multiple Pragma Directives

**Criticality** Minor / Informative

**Location** Disney.sol#L6,97,126,145,169,1306,1371,1417,1765,1837,2052,2115,233
7,2504,2704,2814,2937,2977,3074,3193,3278,3308,3711,3822,4112,416
4

**Status** Unresolved

#### Description

If the contract includes multiple conflicting pragma directives, it may produce unexpected

errors. To avoid this, it's important to include the correct pragma directive at the top of the

contract and to ensure that it is the only pragma directive included in the contract.
```
 pragma solidity ^0.8.0;
 pragma solidity ^0.8.0;
 solidity ^0.8.0;
 solidity ^0.8.9;
 ...

#### Recommendation

```
It is important to include only one pragma directive at the top of the contract and to ensure

that it accurately reflects the version of Solidity that the contract is written in.

By including all required compiler options and flags in a single pragma directive, the

potential conflicts could be avoided and ensure that the contract can be compiled correctly.


-----

