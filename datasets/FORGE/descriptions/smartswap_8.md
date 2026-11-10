#### L09 - Dead Code Elimination

**Criticality** Minor / Informative

**Location** DP2PCoin.sol#L42,66,91,101,120,134,153,163,180,190,207,247,272,288,
324,358,403,416,431,447,482,501,515,528,725
DP2PToken.sol#L21,46,62,98,132,177,190,205,221,256,275,289,302,532,
557,586,619,629,646,656,830,845,857
DP2PTokenLegacyUSDT.sol#L21,46,62,98,132,177,190,205,221,256,275,
289,302,532,557,586,619,629,646,656

**Status** Unresolved

#### Description

In Solidity, dead code is code that is written in the contract, but is never executed or

reached during normal contract execution. Dead code can occur for a variety of reasons,

such as:

  - Conditional statements that are always false.

  - Functions that are never called.

  - Unreachable code (e.g., code that follows a return statement).

Dead code can make a contract more difficult to understand and maintain, and can also

increase the size of the contract and the cost of deploying and interacting with it.


-----

-----

#### Recommendation

To avoid creating dead code, it's important to carefully consider the logic and flow of the

contract and to remove any code that is not needed or that is never executed. This can help

improve the clarity and efficiency of the contract.


-----

